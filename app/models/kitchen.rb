class Kitchen < ActiveRecord::Base
  has_many :appliances_kitchens
  has_many :appliances, :through => :appliances_kitchens
  has_many :meals
  has_many :meal_histories
  has_many :users
  has_many :sort_orders
  has_many :ingredients_kitchens
  has_many :ingredient, :through => :ingredients_kitchens
  has_many :recipes
  validates_presence_of :name
  
  #-------------------------------------------
  def get_sorted_pantry_items
    SortOrder.list_sort(id, :pantry_order, ingredients_kitchens.includes(:ingredient)).
      delete_if {|ik| ik.ingredient.nil?}
  end
  
  #-------------------------------------------
  def get_sorted_shopping_items
    # Just do alphabetical for now (Feb-2012)
    ingredients_kitchens.includes(:ingredient).where('needed = ? AND ingredient_id IS NOT NULL', true).sort_by {|ik| ik.ingredient.name}
    #SortOrder.list_sort(id, :shop_order, ingredients_kitchens.includes(:ingredient).where('needed = ?', true)).
    #  delete_if {|ik| ik.ingredient.nil?}
  end

  # Returns a hash with category names as keys, and arrays of IngrediesntsKitchen
  # objects of this category, both sorted alphabetically
  def get_categories_hash
    categories_arr = {}

    IngredientsKitchen.scoped.joins(ingredient: :categories).
      where('ingredients_kitchens.kitchen_id = ? AND ingredients_kitchens.needed=?', id, true).
      select("categories.name as cat_name, ingredients_kitchens.id as ing_id, ingredients.name as ing_name").
      order('cat_name ASC, ing_name ASC').
      each do |i|

        categories_arr[i.cat_name] = [] unless categories_arr.has_key?(i.cat_name)
        categories_arr[i.cat_name] << IngredientsKitchen.find(i.ing_id)
      end

    categories_arr
  end


  #-------------------------------------------
  def get_sorted_my_meals
    SortOrder.list_sort(id, :meal_order, filter_meals('my_meals'))
  end
  
  #---------------------------------
  def get_exclude_list
    ingredients_kitchens.where(:exclude => true).delete_if {|ik| ik.ingredient.nil?}.sort_by {|ik| ik.ingredient.name}
  end

  #---------------------------------
  def get_have_list
    ingredients_kitchens.where(:have => true).delete_if {|ik| ik.ingredient.nil?}.sort_by {|ik| ik.ingredient.name}
  end

  #-------------------------------------------
  def filter_meals(meals_field = nil)
    meals.delete_if {|m| (!meals_field.nil? && !eval("m.#{meals_field}")) ||
     m.recipe.nil? || m.recipe.name.blank?}
  end
  
  #-------------------------------------------
  def have_ingredients
    have_ingredient_items.map do |ik|
      if ik.ingredient.nil?
        ik.delete
      end
      ik.ingredient
    end.compact || []
  end

  #-------------------------------------------
  def have_ingredient_items
    ingredients_kitchens.includes(:ingredient).where("have = ? AND ingredient_id IS NOT NULL", true).order('ingredients.name')
  end
  
  #-------------------------------------------
  def starred_meal_ingredient_ids
    #recipe_ids = ActiveRecord::Base.connection.select_values("SELECT recipe_id FROM meals WHERE kitchen_id = #{self.id} AND starred = TRUE") 
    # The above is about 30ms faster in some tests since objects are not instantiated, but it doesn't work on sqlite3
    recipe_ids = meals.where(:starred => true).map {|m| m.recipe_id}
    return recipe_ids || []
  end

  #-------------------------------------------
  def my_meals_recipe_ids
    #recipe_ids = ActiveRecord::Base.connection.select_values("SELECT recipe_id FROM meals WHERE kitchen_id = #{self.id} AND my_meals = TRUE") 
    # The above is about 30ms faster in some tests since objects are not instantiated, but it doesn't work on sqlite3
    recipe_ids = meals.where(:my_meals => true).map {|m| m.recipe_id}
    return recipe_ids || []
  end  
  
  #-------------------------------------------
  # Need just ingredient_name. However, other attributes can be added too
  def add_new_pantry_item(ingredient_name, attributes)
    ingr = Ingredient.find_or_create_by_name(ingredient_name, self.id)
    return nil if ingr.nil?

    ik = ingredients_kitchens.find_by_ingredient_id(ingr)
    if ik.nil?
      ik = ingredients_kitchens.create({:ingredient => ingr, :needed => false, :bought => false, :have => false})
    end
    ik.update_attributes!(attributes)
    return ik
  end
  
  #-------------------
  def add_or_update_pantry_ingredient(ingr_id, checked)
    ik = ingredients_kitchens.find_by_ingredient_id(ingr_id)
    if ik.nil?
      ik = ingredients_kitchens.create(:ingredient_id => ingr_id)
    end
    ik.have = checked
    ik.save!
  end
  
  #--------------------------------
  def update_ingredients_kitchens(ingredient_name_or_id, attributes)
    ingr = Ingredient.find_or_create_by_name_or_id(ingredient_name_or_id, self.id)
    return nil if ingr.nil?

    user_ingr = ingredients_kitchens.find_by_ingredient_id(ingr.id)
    if user_ingr.nil?
      user_ingr = ingredients_kitchens.create(:ingredient_id => ingr.id)
    end
    user_ingr.update_attributes!(attributes)
    return user_ingr
  end
  
  #-------------------------------------------
  def done_shopping
    IngredientsKitchen.update_all({:bought => false, :needed => false, :have => true, :weight => 0}, 
      {:kitchen_id => self.id, :bought => true})
  end
  
  #-------------------
  def update_shop_list(ik_id, state, shop_list)
    ik = IngredientsKitchen.find(ik_id)
    if shop_list
      ik.bought = state
    else # pick list
      ik.needed = state
      # if removing from the needed list, also clear the bought flag. Otherwise if they put
      # back on the needed list, it will show up in the shop list as already purchased.
      if !state
        ik.bought = false
      end
    end
    ik.save!
  end  

  #-------------------------------------------
  def remove_from_shopping_list(ik_id)
    IngredientsKitchen.find(ik_id).update_attributes!(:bought => false, :needed => false, :weight => 0)
  end
  
  #-------------------------------------------
  def clear_shopping_list
    IngredientsKitchen.update_all({:bought => false, :needed => false, :weight => 0}, 
      {:kitchen_id => self.id, :needed => true})
  end
  
  #-------------------------------------------
  def add_ingredients_to_shopping_list(ingr_list, recipe_servings)
    
    # Determine how to scale recipe ingredients depending on the servings
    if !recipe_servings.nil? && recipe_servings != 0 && !default_servings.nil? && default_servings != 0
      factor = 1.0 * default_servings / recipe_servings
    else
      factor = 1
    end

    # Add ingredients unless excluded and scale weights 
    ingr_list.each do |ir|
      next if ir.group?
      ik = ingredients_kitchens.find_or_create_by_ingredient_id(ir.ingredient_id)
      next if ik.exclude
      ik.needed = true
      unless ir.weight.nil?
        if ik.weight.nil? 
          ik.weight = ir.weight * factor
        else
          ik.weight += ir.weight * factor  ## TO-DO adjust for possibly different units
        end
      end
      ik.unit = ir.unit
      ik.save!
    end
  end
  
  #-------------------------------------------
  def add_recipe_ingredients_to_shopping_list(recipe_id)
    recipe = Recipe.find(recipe_id)
    add_ingredients_to_shopping_list(recipe.ingredients_recipes, recipe.servings)
  end

  #---------------------------------
  def update_meals(recipe_id, my_meals = true, starred = true)
    m = meals.find_by_recipe_id(recipe_id)
    if m.nil?
      m = meals.create!(:recipe_id => recipe_id)
    end
    m.my_meals = my_meals unless my_meals.nil?
    m.starred = starred unless starred.nil?
    m.save!
  end
    
  #---------------------------------
  def remove_recipe_and_ingredients(recipe_id)
    meals.find_by_recipe_id(recipe_id).update_attributes!(:my_meals => false)

    ingr_ids = Recipe.find(recipe_id).ingredients.map {|i| i.id}
    IngredientsKitchen.update_all({:weight => 0, :have => false}, 
      ["kitchen_id = ? AND have = ? AND ingredient_id in (?)", self.id, true, ingr_ids])
  end
  
  #---------------------------------
  def increment_seen_count(recipe_id)
    return if recipe_id.blank?
    
    m = meals.find_by_recipe_id(recipe_id)
    if m.nil?
      m = meals.create!(:recipe_id => recipe_id)
    end
    m.seen_count = m.seen_count + 1
    m.save!
  end
  
  #---------------------------------
  def find_recipe(recipe_id_or_name)
    if recipe_id_or_name.to_i > 0
      id = recipe_id_or_name.to_i
      recipe = Recipe.where('id = ? AND (public = ? OR kitchen_id = ?)', id, true, self.id)
    else
      name = recipe_id_or_name  
      recipe = Recipe.where('name = ? AND (public = ? OR kitchen_id = ?)', name, true, self.id)
    end
    return recipe
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
     kitchen = Kitchen.create!(:name => kitchen_name, :default_servings => 4)
     kitchen.update_ingredients_kitchens('salt', :exclude => true)
     kitchen.update_ingredients_kitchens('black pepper', :exclude => true)
     return kitchen
  end
 
end
