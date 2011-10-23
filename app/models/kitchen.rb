class Kitchen < ActiveRecord::Base
  has_many :appliances_kitchens
  has_many :appliances, :through => :appliances_kitchens
  has_many :meals
  has_many :users
  has_many :sort_orders
  has_many :ingredients_kitchens
  has_many :ingredients, :through => :ingredients_kitchens
  validates_presence_of :name
  
  DEFAULT_MEAL_DAYS = '12345' # Days of week. 0=Sunday, 1=Monday
  
  #-------------------------------------------
  def update_default_servings(servings)
    self.default_servings = servings
    self.save!
  end
  
  #-------------------------------------------
  def get_food_balance
    return Balance.get_food_balance(self.ingredients_kitchens)
  end
  
  #-------------------------------------------
  def get_sorted_pantry_items
    SortOrder.list_sort(id, :pantry_order, ingredients_kitchens.includes(:ingredient))
  end
  
  #-------------------------------------------
  def get_sorted_shopping_items
    SortOrder.list_sort(id, :shop_order, ingredients_kitchens.includes(:ingredient).where(:needed => true))
  end

  #-------------------------------------------
  def get_sorted_meal_recipes
    SortOrder.list_sort(id, :meal_order, next_recipes)
  end
  
  #-------------------------------------------
  def need_pantry_ingredient?(ingredient)
    ik = ingredients_kitchens.where(:ingredient_id => ingredient.id).first
    return ik.nil? || ik.needed?
  end
  
  #-------------------------------------------
  def add_new_pantry_item(ingredient_name)
    return if ingredient_name.blank?
    name = ingredient_name.chomp.make_singular
    i = Ingredient.find_or_create_by_name(name, :kitchen_id => self.id)
    ik = IngredientsKitchen.create(:ingredient => i, :needed => false, :bought => false)
    ingredients_kitchens << ik
    return ik
  end
  
  #-------------------------------------------
  ## Returns emails of all users under the kitchen
  def users_emails
    users.map {|user| user.email}
  end
  
  #-------------------------------------------
  ## Update the default days of the week the kitchen recipes displays
  def set_default_meal_days(meal_days)
    self.default_meal_days = meal_days.to_s
    self.save!
  end
  
  #-------------------------------------------
  def done_shopping
    bought_list = ingredients_kitchens.where(:bought => true)
    bought_list.each do |item_bought|
      item_bought.update_attributes!(:bought => false, :needed => false)
    end
  end
  
  #-------------------------------------------
  def get_uneaten_recipes(end_date, start_date)
    return_recipes = []
    meals.includes(:courses).where(["scheduled_date >= ? AND scheduled_date <= ? AND courses.is_eaten = ?", start_date, end_date, false]).each do |m|
      return_recipes << m.recipes
    end
    return return_recipes.flatten
  end
  
  #-------------------------------------------
  def planned_meal_shopping_list(end_date, start_date)
    recipe_list = get_uneaten_recipes(end_date, start_date)
    ingr_list = []    
    recipe_list.each do |r|
      ingr_list << r.ingredients.where(:stock_item => false)
    end
    ingr_list.flatten.uniq
  end
  
  #-------------------------------------------
  def add_recipes_to_pantry_and_cart(ingr_list)
    ingr_list.each do |ingr|
      ik = ingredients_kitchens.find_or_create_by_ingredient_id(ingr.id)
      ik.needed = true
      ik.save!
      ingredients_kitchens << ik
    end
  end

  #-------------------------------------------
  def next_recipes
    meals.map {|meal| meal.recipes}.flatten
  end
  
  #######################
  # Class Methods
  #######################

  #-------------------------------------------
  def self.create_default_kitchen(first_name, last_name)
    if last_name.empty? && first_name.empty?
       kitchen_name = "My"
     elsif last_name.empty?
       kitchen_name = first_name
     else
       kitchen_name = last_name
     end
     Kitchen.create!(:name => kitchen_name, :default_meal_days => DEFAULT_MEAL_DAYS, :default_servings => 1)
  end
 
end
