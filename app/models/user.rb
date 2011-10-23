class User < ActiveRecord::Base
  
  #Authlogic
  acts_as_authentic do |c|
     c.login_field = false 
     c.login_field = :email
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
  
  @@current_user = nil

    def self.sign_in(user)
    @@current_user = user
  end

  def self.current_user
    if Rails.env.test?
      return @@current_user  
    else
      super
    end
  end

  ###############################################
  def get_points
    pnts = 0
#    UsersPoint.where(:user_id => self).map {|up| p += up.points.points}
    self.points.map {|p| pnts += p.points}
    return pnts
  end
  ###############################################
  ## Adds an item that the user likes into the UsersIngredient table
  ##
  def add_like_item(ingredient_name)
    return nil if ingredient_name.blank?
    name = ingredient_name.downcase.chomp.make_singular
    ingredient = Ingredient.find_or_create_by_name(name)
    
    # This will create if needed and and to the users_ingredients list if needed
    us = users_ingredients.find_or_create_by_ingredient_id(ingredient.id)
    us.like = true
    us.save!
    
    return ingredient
  end
  
  ###############################################
  def remove_like_item(ingredient_id)  
    UsersIngredient.destroy_all(:ingredient_id => ingredient_id, :user_id => self.id)
  end      

  ###############################################
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
    veg = bal.veg
    return {:protein => protein, :veg => veg, :starch => starch}
  end
  
  def update_target_food_balance(veg, starch, protein)
    bal_id = self.balance_id
    bal = Balance.find_by_id(bal_id)
    bal.veg = veg
    bal.grain = starch
    bal.protein = protein
    bal.save!
  end
  ###########################################################
  ## Returns array of recipe_ids that the user is not allergic to
  ## Usage u.get_allergy_free_recipes  
  def get_allergy_free_mains
    allergen_found = 0
    return_array = []
    Recipe.find(:all).each do |r|
      i = r.ingredients.compact
      
      # for each ingredient
      i.each do |ingr| 
        ## see if user is 
        get_allergy_ids.each do |ua_id|
          if (ingr.allergen1_id == ua_id) or  (ingr.allergen2_id == ua_id) or (ingr.allergen3_id == ua_id)
            allergen_found = 1
            break
          end
        end
      end
      ## add recipe to return_array only if no allergens in it 
      if (allergen_found == 0) && r.tags && r.tags.include?("main")  
        return_array << r.id
      end
      allergen_found = 0
    end  

    return return_array
  end
  
  ###########################################################
  ## Populates user_recipes table using user Customize settings
  ## Usage u.generate_recommendations 
  ## Future upgrades:
  ## sort according to like, dislike
  def generate_user_recipes
    get_allergy_free_mains.each do |recipe_id|
      add_recipe(recipe_id, "generate_user_recipes")
    end
  end
  
  #############################################################
  ## Cleans up the user_recipes list when new allergies are selected
  ## Usage u.clean_up_user_recipes
  ## Called from customize_controller.rb
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
  ###########################################################
  ## Returns all recommended users recipes in array, name only
  ## Usage u.get_recipes_names[cnt]
  def get_recipe_names
    users_recipes.map {|ur| ur.recipe.name}
  end
  
  ###########################################################
  ## Returns all recommended users recipes records, Recipe class 
  ## Usage u.get_recipes_list[cnt].original
  def get_recipes_list
    users_recipes.map {|ur| ur.recipe}
  end
  
  ###########################################################
  ## Adds recommended recipe to users_recipes table
  ## Usage u.add_recipe(325,"discover")
  def add_recipe(recipe_id, source, rating=nil)
    user_recipe = users_recipes.where(:recipe_id => recipe_id).first
    if user_recipe.nil?
      user_recipe = users_recipes.create!(
        :user_id => self.id,
        :recipe_id => recipe_id,
        :source => source,
        :rating => rating,
        :date_added => Time.now,
        :active => true)  
      users_recipes << user_recipe  
    else
      unless user_recipe.active #record exists but is false, set to active
        user_recipe.active = true
        user_recipe.source = source  #update the source
        user_recipe.rating = rating unless rating.nil?
        user_recipe.save!
      end
    end
    return user_recipe
  end

  ###########################################################
  def deactivate_recipe(recipe_id)
    user_recipe = users_recipes.where(:recipe_id => recipe_id).first
    user_recipe.active = false
    user_recipe.save!
  end
  
  ###########################################################
  def update_recipe_rating(recipe_id, rating)
    user_recipe = users_recipes.where(:recipe_id => recipe_id).first
    user_recipe.rating = rating
    user_recipe.save!
  end
  
  ##########################################################
  ## Usage: u.get_recipe_rating(435)  
  def get_recipe_rating(recipe_id)
    ur = users_recipes.find_by_recipe_id(recipe_id)
    return ur.rating
  end
  
  ###########################################################
  ## retrieves all active recipe for the user.. returns recipe_ids
  ## Usage: u.get_active_recipe_ids 
  def get_active_recipe_ids
    users_recipes.find_all {|ur| ur.active}.map {|ur| ur.recipe_id}
  end  
  
  ###########################################################
  def get_active_recipes
    users_recipes.find_all {|ur| ur.active}.map {|ur| ur.recipe}
  end  
  
  ###########################################################
  ## Returns a recipe that fits user requirements, and contains the desired tag
  ## 
  ## Usage: User.create_meal(:dinner, Time.now + (60*60*24*2)) 
  def add_meal(meal_type_symbol, date)
    
    # Find the meal_type_id to search. If not found, look for the first one.
    meal_type_id = MealType.find_by_name(meal_type_symbol.to_s).id
    meal_type_id = MealType.find(:first).id if meal_type_id.nil?
    
    m = Meal.where(:kitchen_id => self.kitchen_id, :scheduled_date => date, :meal_type_id => meal_type_id)[0]
    if m.nil?  # if the meal doesn't already exist, create meal
      Meal.create(
      :kitchen_id => self.kitchen_id,
      :meal_type_id => meal_type_id,
      :scheduled_date => date)
    else
      return m
    end
  end
  
  ###########################################################
  ## Returns all allergies associated with the user
  ## Returns the name of the allergy as looked up in the Allergy table
  ## Usage: User.get_allergy_names  --> ["beechnut", "milk"]
  ## Usage: u.get_basic_allergy_list -->  [["soy", true], ["milk", false]]
  def get_allergy_names
    allergies.map {|a| a.name}
  end
  
  def get_basic_allergy_list
    return_array = []
    Allergy.find(:all, :conditions => {:display => "yes", :parent_id => nil}).each do |allergy|
      selected = get_allergy_names.include?(allergy.name)
      return_array << {:name => allergy.name, :value => allergy.name, :selected => selected}
    end
    return return_array
  end
  
  def update_basic_allergy_list(allergy_names)
    allergies.delete_all
    unless allergy_names.nil?
      allergy_names.each do |allergy_name|
        add_allergy(allergy_name)
      end
    end
  end
    
  ###########################################################
  def get_allergy_ids
    allergies.map {|a| a.id}
  end
  
  ###########################################################
  ## Adds Allergy to link table for a user
  ## Usage:  User.add_allergy("fish")
  ##
  def add_allergy(allergy_name)
    
    allergy = Allergy.find_by_name(allergy_name)
    allergies << allergy unless allergies.include?(allergy)
    
    if allergy.parent_id.nil? 
      allergy.suballergies_names.each do |sub_name|
        allergy = Allergy.find_by_name(sub_name)
        allergies << allergy unless allergies.include?(allergy)
      end
    end
  end
  
  ###########################################################
  ## Destroys Allergy and any suballergies link table for a user
  ## Usage:  User.destroy_allergy("fish")
  ##  
  def destroy_allergy(allergy_name)
    destroy_one_allergy(allergy_name)
    a = Allergy.find_by_name(allergy_name)    
    
    ## if the allergy_name is a parent allergy, destroy suballergies too
    if a.parent_id.nil?  
     (0..self.get_allergy_names.length-1).each do |cnt|    
        if a.suballergies_names.include?(self.get_allergy_names[cnt]) 
          destroy_one_allergy(get_allergy_names[cnt])
        end
      end
    end
  end


  #---------------------------------
  def to_label
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

      unless saved[:recipes].nil?
        saved[:recipes].each do |recipe_id|
          user.add_recipe(recipe_id, 'welcome')
        end
      end
    end
    return user
  end
    
  ##################################
  protected
  
  ###########################################################
  ## Destroys Allergy from link table for a user
  ## Called by destroy_allergy which loops through any suballergies as well
  ## Usage:  User.destroy_one_allergy("fish")
  ##
  def destroy_one_allergy(allergy_name)
    index = users_allergies.index {|ua| ua.allergy.name == allergy_name}
    unless index.nil?
      users_allergies[index].destroy
    end
  end
  
  
end
