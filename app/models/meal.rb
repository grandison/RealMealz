class Meal < ActiveRecord::Base
  belongs_to :meal_type
  belongs_to :kitchen
  has_many :courses, :order => "order_num ASC"
  has_many :recipes, :through => :courses
  default_scope :include => [:courses, :recipes]
  
  attr_accessor :just_created

  validates_presence_of :kitchen_id, :meal_type_id, :scheduled_date

  ######################################################
  def name
    "Meal-#{self.id}"
  end

  ######################################################
  def scheduled_date_name
    Date::DAYNAMES[scheduled_date.wday]
  end

  ######################################################
  def reset_course_order     
    courses(true).each_with_index do |course, index| 
      if course.order_num != index
        course.order_num = index
        course.save!
      end
    end
  end

  ######################################################
  ## Modifies courses table on a specifc recipe_id /meal_id pair to is_eaten=true
  ## Modifies all instances if multiple instances of recipe_id appears with meal_id
  ## ie.. person has multiple of the same spaghetti recipes at a specific "lunch" 
  ## Usage: Meal.ate_recipe(364)
  def ate_recipe(recipe_id)
    courses.where(:recipe_id => recipe_id).each do |c| 
      c.is_eaten = true 
      c.save!
    end
  end

  ######################################################
  ## Returns recipe names associated with the meal
  def recipes_names
    courses(:all).map {|c| c.recipe.name}
  end

  #######################################################
  def add_recipe_lists
    courses.each do |course|
      course.add_recipe_list
    end
  end

  #######################################################
  def add_course(new_recipe_id = nil)
    course = Course.create_course(new_recipe_id)
    courses << course
    save!
    reset_course_order
    return course
  end

  #######################################################
  # Class methods
  #######################################################

  #######################################################
  def self.find_or_create_meal(date, meal_type, kitchen_id)
    meal_type = MealType.find_by_name(meal_type.to_s) || MealType.find(:first)
    
    conditions = {:kitchen_id => kitchen_id, :scheduled_date => date, :meal_type_id => meal_type.id}
    meal = Meal.where(conditions).first 
    if meal.nil?
      meal = Meal.create(conditions)
      meal.just_created = true
    else
      meal.just_created = false
    end
    return meal
  end

  #######################################################
  def self.get_next_meals(num_of_meals, start_date, meal_type, kitchen_id)
    default_days = Kitchen.find(kitchen_id).default_meal_days || Kitchen::DEFAULT_MEAL_DAYS
    next_meals = []
    (0..num_of_meals - 1).each do |days_from_now|
      date_then = start_date.to_date + days_from_now.days
      meal = Meal.find_or_create_meal(date_then, meal_type, kitchen_id)
      next_meals << meal
      # add a course only if this is a new meal, it is a scheduled day and there aren't existing courses
      if meal.just_created && default_days.include?(meal.scheduled_date.wday.to_s[0]) && (meal.courses.length == 0)
        meal.add_course
        meal.just_created = false
      end
    end
    next_meals
  end

  #######################################################
  def self.setup_initial(num_of_meals, date, meal_type, kitchen_id)
    next_meals = Meal.get_next_meals(num_of_meals, date, meal_type, kitchen_id).each do |meal|
      meal.add_recipe_lists
    end
    return next_meals
  end

end
