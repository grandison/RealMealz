class Course < ActiveRecord::Base
  belongs_to :meal
  belongs_to :recipe
  
  attr_accessor :recipe_list

  ###########################################################
  def add_recipe_list
    # Get active recipes, if not enough, fill in
    user_recipes = Array.new(User.current_user.get_active_recipes)
    if user_recipes.length < 10 
      user_recipes += Recipe.find(:all, :limit => 10)
    end  
    
    # Randomize 
    user_recipes = user_recipes.sample(user_recipes.length)  

    # Find the current recipe, if none then grab the first one, otherwise put current first
    if recipe_id.nil?
      index = nil
    else
      index = user_recipes.index {|recipe| recipe.id == recipe_id}
    end
    
    if index.nil?
      self.recipe_id = user_recipes[0].id
      save!
    else
      current_recipe = user_recipes.delete_at(index)
      user_recipes = [current_recipe] + user_recipes
    end  
    
    self.recipe_list = user_recipes
  end

  ###########################################################
  # Class methods
  ###########################################################

  ###########################################################
  def self.get_kitchen_courses(kitchen)
    find(:all, :joins => :meal, :conditions => ["meals.kitchen_id = ?", kitchen.id])
  end

  ############################################################
  def self.create_course(new_recipe_id = nil) 
    # create new course. Give it high order number to put it last in sort order
    # new_recipe_id can be nil in which case it will be assigned a random recipe in add_recipe_list
    Course.create(:recipe_id => new_recipe_id, :order_num => Course.count, :servings => 4)
  end
  
  ###########################################################
  def self.update_course(course_id, recipe_id)
    raise ArgumentError, 'Recipe_id is nil' if recipe_id.nil?
    Course.update(course_id, :recipe_id => recipe_id)
  end

  ###########################################################
  def self.find_course(date, meal_type_symbol, kitchen_id, order_num)
    joins(:meal => :meal_type).where(:order_num => order_num,
    :meals => {:scheduled_date => date, :kitchen_id => kitchen_id,
    :meal_types => {:name => meal_type_symbol.to_s}}).first
  end
  
  ###########################################################
  def self.delete_and_reorder(course_id)
    course = find(course_id)
    course.destroy
#    course.meal.reset_course_order
  end

  ###########################################################
  def self.delete_course_by_recipe(recipe_id)
    destroy_all(:recipe_id => recipe_id)
  end

end
