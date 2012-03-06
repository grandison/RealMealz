class Meal < ActiveRecord::Base
  belongs_to :kitchen
  belongs_to :recipe
  has_many :meal_histories
  
  #----------------------------------
  def name
    "Meal-#{self.id}"
  end

  #----------------------------------
  def scheduled_date_name
    Date::DAYNAMES[scheduled_date.wday]
  end

  #----------------------------------
  def ate_recipe(recipe_id)
    self.where(:recipe_id => recipe_id).each do |m| 
      m.is_eaten = true 
      m.save!
    end
  end

  #----------------------------------
  def recipes_names
    self.map {|c| c.recipe.name}
  end

  ##################################
  # Class methods
  ##################################

  #----------------------------------
  def self.find_or_create_meal(date, meal_type, kitchen_id, recipe_id)
    meal_type = MealType.find_by_name(meal_type.to_s) || MealType.find(:first)
    
    conditions = {:kitchen_id => kitchen_id, :scheduled_date => date, :meal_type_id => meal_type.id, :recipe_id => recipe_id}
    meal = Meal.where(conditions).first 
    if meal.nil?
      meal = Meal.create(conditions)
    end
    return meal
  end
  
  #----------------------------------
  def self.delete_meal_by_recipe(recipe_id)
    destroy_all(:recipe_id => recipe_id)
  end

end
