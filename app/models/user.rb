class User < ActiveRecord::Base

  #Authlogic
  acts_as_authentic do |c|
    c.login_field = false 
    c.login_field = :email
    c.disable_perishable_token_maintenance = true
    c.maintain_sessions = false if Rails.env.test? # Needed so tests will work
  end 

  # Setup accessible (or protected) attributes for your model
  attr_accessor :invite_code, :team_id # These are for convenience to make it easier to process form input
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first, :last, :invite_code, :team_id
  attr_reader :recipe_list 
  
  belongs_to :kitchen
  has_one :balance
  has_many :users_allergies
  has_many :allergies, :through => :users_allergies
  has_many :users_personalities
  has_many :personalities, :through => :users_personalities
  has_many :users_sliding_scales
  has_many :sliding_scales, :through => :users_sliding_scales
  has_many :users_categories
  has_many :categories, :through => :users_categories
  has_many :users_recipes
  has_many :recipes, :through => :users_recipes
  has_many :users_ingredients
  has_many :ingredients, :through => :users_ingredients
  has_many :users_points
  has_many :points, :through => :users_points
  has_many :users_groups
  has_many :groups, :through => :users_groups
  has_many :users_teams
  has_many :teams, :through => :users_teams

  # MD This causes Ruby to use too much memory
  #default_scope :include => [:allergies, :users_recipes, {:recipes => :ingredients}]

  ROLES = %w(super_admin, kitchen_admin, member, guest)

  validates_presence_of :first, :last, :email
  validates_uniqueness_of :email
  validate :valid_invite_code

  #--------------------------------
  def valid_invite_code
    errors.add(:invite_code, "'#{invite_code}' is not valid") unless invite_code.blank? || InviteCode.check_code(invite_code)
  end
  
  #--------------------------------
  # Pass ingredient name or id. Will create kitchen ingredient if needed
  # Set like or avoid in the attributes: :like => true, :avoid => false
  def update_users_ingredients(ingredient_name_or_id, attributes)
    ingr = Ingredient.find_or_create_by_name_or_id(ingredient_name_or_id, self.kitchen_id)
    return nil if ingr.nil?

    user_ingr = users_ingredients.find_by_ingredient_id(ingr.id)
    if user_ingr.nil?
      user_ingr = users_ingredients.create(:ingredient_id => ingr.id)
    end
    user_ingr.update_attributes!(attributes)
    return user_ingr
  end
  
  #---------------------------------
  # MD Apr-2012. like_avoid here is expected to be the symbols :like or :avoid. However, in the settings_controller,
  # like_avoid is a hash with {:like => true} or {:like => false}. To be able to support both of these
  # convert if necessary
  def get_like_avoid_list(like_avoid)
    if like_avoid.class == Hash
      like_avoid = like_avoid[:like] ? :like : :avoid
    end
    users_ingredients.where(like_avoid => true).delete_if {|ui| ui.ingredient.nil?}.sort_by {|ui| ui.ingredient.name}
  end

  #---------------------------------
  ## Returns food balance target of the user
  def get_target_food_balance
    bal_id = nil
    if self.balance_id.nil? or self.balance_id == 0
      ## Add new standard balance
      new_balance = Balance.create_default_balance(self.id)
      self.balance_id = new_balance.id
      self.save!
      bal_id = new_balance.id
    else
      bal_id = self.balance_id
    end

    bal = Balance.find_by_id(bal_id)
    protein = bal.protein
    starch = bal.grain
    vegetable = bal.veg
    return {:protein => protein, :vegetable => vegetable, :starch => starch}
  end

  #---------------------------------
  def update_target_food_balance(vegetable, starch, protein)
    bal_id = self.balance_id
    bal = Balance.find_by_id(bal_id)
    bal.veg = vegetable
    bal.grain = starch
    bal.protein = protein
    bal.save!
  end

  #---------------------------------
  ## Cleans up the user_recipes list when new allergies are selected
  ## Usage u.clean_up_user_recipes
  ##
  def clean_up_user_recipes

    allergen_found = 0

    self.recipes.each do |r|
      i = r.ingredients.compact

      # for each ingredient
      i.each do |ingr| 
        ## see if user is allergic
        get_allergy_ids.each do |ua_id|
          if (ingr.allergen1_id == ua_id) or  (ingr.allergen2_id == ua_id) or (ingr.allergen3_id == ua_id)
            allergen_found = 1
            break
          end
        end
      end
      ## set active to false if user has selected an allergy that conflicts with the recipe
      if allergen_found == 1  
        ur = UsersRecipe.find(:first, :conditions => {:user_id => self.id, :recipe_id => r.id})
        ur.active = false
        ur.save! 
      end
      allergen_found = 0
    end  
  end

  #---------------------------------
  ## Returns all recommended users recipes in array, name only
  ## Usage u.get_recipes_names[cnt]
  def get_recipe_names
    users_recipes.map {|ur| ur.recipe.name}
  end

  #---------------------------------
  def get_favorite_recipes(recipe_ids_shown, filters)
    start_time = Time.now 
    cache_miss = false
    
    
    # Get avoid ingredients and all ingredients which have the same category name
    # This will allow someone to enter "meat" and screen for all types of meats, i.e. beef, chicken, pork, etc.
    # For this to work, there needs to be an ingredient with the same name as a category
    avoid_users_ingredients = users_ingredients.where(:avoid => true).select('ingredient_id')
    
    avoid_ingredient_ids = [] 
    avoid_users_ingredients.each do |avoid|
      avoid_ingredient_ids << avoid.ingredient.id
      category = Category.find_by_name(avoid.ingredient.name)
      unless category.nil?
         avoid_ingredient_ids << category.categories_ingredients.map {|ci| ci.ingredient_id}
      end
    end
    avoid_ingredient_ids.flatten!
    
    like_ingredient_ids = users_ingredients.where(:like => true).select('ingredient_id').map{|ui| ui.ingredient_id}
    kitchen_meals = Meal.where(:kitchen_id => kitchen.id)
   
    public_recipe_list = Rails.cache.fetch("public_recipe_list", :expires_in => 1.hour) do
      cache_miss = true
      create_recipe_list(['public = ? AND picture_file_name IS NOT NULL', true]) 
    end || []

    private_recipe_list = Rails.cache.fetch("private_recipe_list_id_#{self.id}", :expires_in => 1.hour) do
      create_recipe_list(['kitchen_id = ?', self.kitchen_id])  #Ok to show private recipes without a picture
    end || []
    @recipe_list = public_recipe_list + private_recipe_list

    if filters.nil?
      filters = {}
    end
    
    starred_recipe_ids = []
    if filters['star']
      starred_recipe_ids = kitchen.meals.where(:starred => true).map {|m| m.recipe_id}
      @recipe_list.delete_if {|r| !starred_recipe_ids.include?(r[:id])} unless starred_recipe_ids.blank?
    end
    search_for = (filters['search'] || '').downcase

    @recipe_list.each do |rh|
      next unless starred_recipe_ids.blank? || starred_recipe_ids.include?(rh[:id])
      
      rh[:ingredients].each do |ih|
        # Add 10 for each like ingredient
        rh[:scores][:ingr_like] = 10 if like_ingredient_ids.include?(ih[:id])
      
        # Add 100 if filtering and matches ingredient
        rh[:scores][:ingr_have] = 100 if filters['ingredients'] && filters['ingredient_ids'].include?(ih[:id].to_s)
      
        # Subtract 20 if in avoid
        rh[:scores][:avoid] = -40 if avoid_ingredient_ids.include?(ih[:id])
      
        # Allergies currently not used, so comment out for now
        # Subtract 100 if in allergy
        #rh[:scores][:allergy] -= 100 if allergy_ingredient_ids.include?(ih[:allergen1_id]) ||
        #  allergy_ingredient_ids.include?(ih[:allergen2_id]) ||
        #  allergy_ingredient_ids.include?(ih[:allergen3_id])
        
        # Add 100 if search matches ingredient
        rh[:scores][:ingr_search] = 100 if rh[:ingredients].index {|i| ih[:other_names].include?(search_for)} unless search_for.blank?
      end
      
      meal = kitchen_meals.find {|m| m.recipe_id == rh[:id]}
      unless meal.nil? 
      
        # Subtract 100 for each time seen, except if searching
        if search_for.blank?
          rh[:scores][:seen] = -100 * meal.seen_count 
        end
      
        # Subtract 75 if in my meals, else if searching add 50
        if search_for.blank?    
          rh[:scores][:my_meals] = -75 if meal.my_meals?
        else
         rh[:scores][:my_meals] = 50 if meal.my_meals?
        end
      
        # Subtract 50 if starred, else if searching add 50
        if search_for.blank?    
          rh[:scores][:star] = -50 if meal.starred?
        else
          rh[:scores][:star] = 50 if meal.starred?
        end
      end
      
      # Take off 500 if it is already in the user's browsers queue
      rh[:scores][:seen] = -500 if recipe_ids_shown.include?(rh[:id])
      
      # Add 300 if search is in title      
      rh[:scores][:title_search] = 300 if rh[:name].downcase.include?(search_for) unless search_for.blank?
    
      # Add some variability unless testing
      rh[:scores][:random] = rand(30).to_i unless Rails.env.test?
      
      # Add up scores
      rh[:sort_score] = 0
      rh[:scores].each {|k, v| rh[:sort_score] += v} 
    end

   recipe_list_ids = @recipe_list.sort! {|rh1, rh2| rh2[:sort_score] <=> rh1[:sort_score]}.map {|rh| rh[:id]}

    end_time = Time.now
    r = Recipe.find(recipe_list_ids.first)
    rh = @recipe_list.find {|rh| rh[:id] == r.id}
    Rails.logger.info "===> get_favorite_recipes: Cache hit=#{!cache_miss}, Total time =#{end_time - start_time}"
    Rails.logger.info "     First recipe=#{rh[:name]}, score=#{rh[:sort_score]}"
    Rails.logger.info "     Filters=#{filters.to_json}"
    Rails.logger.info "     Scores=#{rh[:scores].to_json}"
    
    return recipe_list_ids
  end

  #---------------------------------
  def get_next_recipe(recipe_ids_shown, filters = nil)
    recipes = get_favorite_recipes(recipe_ids_shown, filters)
    recipes.first
  end

  #---------------------------------
  def update_recipe_rating(recipe_id, rating)
    user_recipe = users_recipes.where(:recipe_id => recipe_id).first
    user_recipe.rating = rating
    user_recipe.save!
  end

  #---------------------------------
  ## Usage: u.get_recipe_rating(435)  
  def get_recipe_rating(recipe_id)
    ur = users_recipes.find_by_recipe_id(recipe_id)
    return ur.rating
  end

  #---------------------------------
  ## retrieves all active recipe for the user.. returns recipe_ids
  ## Usage: u.get_active_recipe_ids 
  def get_active_recipe_ids
    users_recipes.find_all {|ur| ur.active}.map {|ur| ur.recipe_id}
  end  

  #---------------------------------
  def get_box_recipe_ids
    users_recipes.where('in_recipe_box = ?', true).map {|ur| ur.recipe_id}
  end  

  #---------------------------------
  def get_active_recipes
    users_recipes.find_all {|ur| ur.active}.map {|ur| ur.recipe}
  end  

  #---------------------------------
  ## Returns all allergies associated with the user
  ## Returns the name of the allergy as looked up in the Allergy table
  ## Usage: User.get_allergy_names  --> ["beechnut", "milk"]
  ## Usage: u.get_basic_allergy_list -->  [["soy", true], ["milk", false]]
  def get_allergy_names
    allergies.map {|a| a.name}
  end

  #---------------------------------
  def get_basic_allergy_list
    return_array = []
    Allergy.find(:all, :conditions => {:display => "yes", :parent_id => nil}).each do |allergy|
      selected = get_allergy_names.include?(allergy.name)
      return_array << {:name => allergy.name, :value => allergy.name, :selected => selected}
    end
    return return_array
  end

  #---------------------------------
  def update_basic_allergy_list(allergy_names)
    allergies.delete_all
    unless allergy_names.nil?
      allergy_names.each do |allergy_name|
        add_allergy(allergy_name)
      end
    end
  end

  #---------------------------------
  def add_allergy(allergy_name)
    allergy = Allergy.find_by_name(allergy_name)
    return nil if allergy.nil?
    allergies << allergy unless allergies.include?(allergy)

    if allergy.parent_id.nil? 
      allergy.suballergies_names.each do |sub_name|
        allergy = Allergy.find_by_name(sub_name)
        allergies << allergy unless allergies.include?(allergy)
      end
    end
  end

  #---------------------------------
  def destroy_allergy(allergy_name)
    destroy_users_allergy_by_name(allergy_name)
    a = Allergy.find_by_name(allergy_name)    

    ## if the allergy_name is a parent allergy, destroy suballergies too
    if a.parent_id.nil?  
      get_allergy_names.each do |name|    
        if a.suballergies_names.include?(name) 
          destroy_users_allergy_by_name(name)
        end
      end
    end
  end

  #---------------------------------
  def get_allergy_ids
    allergies.map {|a| a.id}
  end

  #---------------------------------
  def get_sorted_allergies
    allergies.sort_by {|a| a.name}
  end

  #---------------------------------
  def name
    "#{first} #{last}"
  end

  #---------------------------------
  def role?(test_role)
    self.role == test_role.to_s
  end

  #---------------------------------
  def create_kitchen_if_needed
    return unless kitchen.nil?
    self.kitchen = Kitchen.create_default_kitchen(first, last)
    self.save!
    return kitchen
  end

  #---------------------------------
  def get_points
    sum = 0
    points.each {|p| sum += p.points}
    return sum
  end

  #--------------------------------
  def check_add_points(controller_name, action_name)
    point = Point.find_by_name("#{controller_name}:#{action_name}")
    return nil if point.nil?

    num = users_points.where('point_id = ?', point.id).size
    return nil if num >= point.max_times

    users_points.create(:point_id => point.id, :date_added => Time.now)
  end
  
  #--------------------------------
  def deliver_password_reset_instructions!
    reset_perishable_token!
    SiteMailer.password_reset_instructions(self).deliver!
  end
  
  #--------------------------------
  # MD Apr-2012. The invite code was already checked when the user was created, so let it bomb here if not found
  # However, still use check_code because it downcases before retrieving
  def join_group(invite_code)
    invite = InviteCode.check_code(invite_code)
    self.users_groups.create!(:invite_code_id => invite.id, :group_id => invite.group_id, :join_date => Date.today)
  end      

  #--------------------------------
  # MD Apr-2012. The user should already belong to this group.
  # So first, find the group 
  # Then, check they are already in a team in this group, (or a nil group because of an earlier bug) 
  # If so, just update the record because they are changing teams
  # Otherwise, add a new users_teams record
  def join_team(team_id)
    group = Team.find(team_id).group
    users_team = self.users_teams.where('group_id = ? OR group_id IS NULL', group.id).first
    if users_team
      users_team.update_attributes!(:team_id => team_id, :group_id => group.id)
    else
      self.users_teams.create!(:team_id => team_id, :group_id => group.id)
    end
  end  
  
  #--------------------------------
  def group_welcome_page
    if self.groups.count == 0
      '/home/welcome'
    else
      "/home/welcome?id=#{self.groups.last.id}"
    end
  end
  
  #--------------------------------
  def update_and_join_group(params)
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation)
    end
    if self.update_attributes(params)
      self.join_group(params[:invite_code]) unless params[:invite_code].blank?
    end  
  end
  
  ##################################
  # Class methods
  ##################################

  #---------------------------------
  def User.standard_levels
    [nil] + (-5..5).map {|n| n.to_s}.reverse
  end

  #---------------------------------
  def User.standard_positive_levels
    [nil] + (1..5).map {|n| n.to_s}.reverse
  end

  #---------------------------------
  def User.create_with_saved(saved, temporary_user_id = nil)
    saved = saved.with_indifferent_access
    
    if temporary_user_id.present?
      user = User.find(temporary_user_id)
      if user
        if user.role != 'temp'  # MD Apr-2012. Make sure this really is a temp user
          user = nil
        else
          user.update_attributes(saved)
          user.kitchen.update_attributes(:name => user.last)
        end
      end    
    end
    
    if user.nil?
      user = User.new(saved)
    end  
    
    if user.save
      user.role = 'kitchen_admin'
      user.save!
      user.create_kitchen_if_needed
      user.update_basic_allergy_list(saved[:allergies])
      user.join_group(saved[:invite_code]) unless saved[:invite_code].blank?
    end
    return user
  end
  
  #---------------------------------
  # MD Apr-2012. Create a temporaray user
  # A user needs to have a unique email and a password to be created.
  # We don't want anyone (hackers) logging in with this account so we need to create a password that no-one will guess
  # Likewise, we want to make sure that the email is unique so the insertion doesn't fail. We also want this to be
  # different from the password because otherwise, the password will be stored in cleartext
  # Use the id of this record as the last name so screen will show "Temp 67" for the username
  # Also, give it some random meals so the Shop and Cook pages look better on first use
  def User.create_temporary
    temp_password = Authlogic::Random.friendly_token
    temp_email = Authlogic::Random.friendly_token
    user = User.create!(:first => "Temp", :last => "(placeholder)", :email => "temp_#{temp_email}@email.com",
    :password => temp_password, :password_confirmation => temp_password)
    user.role = 'temp'
    user.last = user.id.to_s
    user.save!
    user.create_kitchen_if_needed
    0.upto(5) do
      recipe = Recipe.random_background_image
      user.kitchen.update_meals(recipe.id) if recipe # MD Apr-2012. Was sometimes giving a nil recipe, don't know why
    end
    return user
  end

  ##################################
  private
  ##################################

  #---------------------------------
  def destroy_users_allergy_by_name(allergy_name)
    allergy = Allergy.find_by_name(allergy_name)
    return nil if allergy.nil?
    ua = users_allergies.find_by_allergy_id(allergy.id)
    return nil if ua.nil?
    ua.destroy
  end

  #---------------------------------
  def create_recipe_info_hash(r)
   {:id => r.id, :name => r.name, :picture_file_name => r.picture_file_name, :sort_score => 0,
    :scores => {:ingr_like => 0, :ingr_have => 0, :avoid => 0, :allergy => 0, :ingr_search => 0, :seen => 0,
      :my_meals => 0, :star => 0, :title_search => 0, :random => 0},
    :ingredients => r.ingredients.map {|i| {:id => i[:id], :other_names => i.other_names.downcase,
        :allergen1_id => i.allergen1_id, :allergen2_id => i.allergen2_id, :allergen3_id => i.allergen3_id} } }
  end

  #---------------------------------
  def create_recipe_list(conditions)
      Recipe.where(conditions).includes('ingredients').select('id, name, picture_file_name').
        map { |r| create_recipe_info_hash(r) }
  end
  
end
