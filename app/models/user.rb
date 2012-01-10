class User < ActiveRecord::Base

  #Authlogic
  acts_as_authentic do |c|
    c.login_field = false 
    c.login_field = :email
    c.disable_perishable_token_maintenance = true
    c.maintain_sessions = false if Rails.env.test? # Needed so tests will work
  end 

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first, :last

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

  # MD This causes Ruby to use too much memory
  #default_scope :include => [:allergies, :users_recipes, {:recipes => :ingredients}]

  ROLES = %w(super_admin, kitchen_admin, member, guest)

  validates_presence_of :first, :last, :email
  validates_uniqueness_of :email

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
  def get_like_avoid_list(like_avoid)
    users_ingredients.where(like_avoid => true).delete_if {|ui| ui.ingredient.nil?}.sort_by {|ui| ui.ingredient.name}
  end

  #---------------------------------
  def get_exclude_list
    kitchen.ingredients_kitchens.where(:exclude => true).delete_if {|ik| ik.ingredient.nil?}.sort_by {|ik| ik.ingredient.name}
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
    allergy_ingredient_ids = allergies.map{|a| a.id}
    like_ingredient_ids = users_ingredients.where(:like => true).map{|ui| ui.ingredient_id}
    avoid_ingredient_ids = users_ingredients.where(:avoid => true).map{|ui| ui.ingredient_id}
    recipe_list = Recipe.includes(:ingredients, :meals).where('public = ? or kitchen_id = ?', true, self.kitchen_id).delete_if do |r|
      r.blank? || (r.picture_file_name.blank? && r.kitchen_id != self.kitchen_id) || recipe_ids_shown.include?(r.id)
    end  

    if filters.nil?
      filters = {}
    end
    if filters['star']
      starred_recipe_ids = kitchen.meals.where(:starred => true).map {|m| m.recipe_id}
      starred_recipe_list = recipe_list.dup.delete_if {|r| !starred_recipe_ids.include?(r.id) }
      if starred_recipe_list.size >= 1
        recipe_list = starred_recipe_list 
      end
    end
    search_for = (filters['search'] || '').downcase
      
    recipe_list.each do |r|
      r.sort_score = 0
      r.ingredients.each do |i|
        # Add 10 for each like ingredient
        r.sort_score += 10 if like_ingredient_ids.include?(i.id)
        
        # Add 100 if filtering and matches ingredient
        r.sort_score += 100 if filters['ingredients'] && filters['ingredient_ids'].include?(i.id.to_s)
        
        # Subtract 20 if in avoid
        r.sort_score -= 20 if avoid_ingredient_ids.include?(i.id)
        
        # Subtract 100 if in allergy
        r.sort_score -= 100 if allergy_ingredient_ids.include?(i.allergen1_id) ||
          allergy_ingredient_ids.include?(i.allergen2_id) ||
          allergy_ingredient_ids.include?(i.allergen3_id)
          
        # Add 100 if search matches ingredient
        r.sort_score += 100 if r.ingredients.index {|i| i.name.downcase.include?(search_for)} unless search_for.blank?
      end

      meal = Meal.where(:recipe_id => r.id, :kitchen_id => self.kitchen_id).first
      unless meal.nil? 
        
        # Subtract 100 for each time seen, except if searching
        if search_for.blank?
          r.sort_score -= 100 * meal.seen_count 
        end
        
        # Subtract 75 if in my meals, else if searching add 50
        if search_for.blank?    
          r.sort_score -= 75 if meal.my_meals
        else
          r.sort_score += 50 if meal.my_meals
        end
        
        # Subtract 50 if starred, else if searching add 50
        if search_for.blank?    
          r.sort_score -= 50 if meal.starred
        else
          r.sort_score += 50 if meal.starred
        end
      end
    
      # Add 300 if search is in title      
      r.sort_score += 300 if r.name.downcase.include?(search_for) unless search_for.blank?
      
      # Add some variability
      r.sort_score += rand(30).to_i
    end

    recipe_list.sort! {|r1, r2| r2.sort_score <=> r1.sort_score}
    # Rails.logger.debug('==> Recipe score: ' + recipe_list.map {|r| "#{r.name}: #{r.sort_score}"}.to_json)
    return recipe_list
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
  def User.create_with_saved(saved)
    saved = saved.with_indifferent_access
    user = User.new(saved)
    if user.save
      user.role = 'kitchen_admin'
      user.save!
      user.create_kitchen_if_needed
      user.update_basic_allergy_list(saved[:allergies])
    end
    return user
  end

  #---------------------------------
  ##################################
  protected
  ##################################

  def destroy_users_allergy_by_name(allergy_name)
    allergy = Allergy.find_by_name(allergy_name)
    return nil if allergy.nil?
    ua = users_allergies.find_by_allergy_id(allergy.id)
    return nil if ua.nil?
    ua.destroy
  end

end
