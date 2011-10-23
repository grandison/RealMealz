class CookController < ApplicationController

  skip_before_filter :require_super_admin
  before_filter :require_user

  def cook
    current_user.generate_user_recipes
    @meal_recipes = current_user.kitchen.get_sorted_meal_recipes
    @option_recipes = Recipe.find_similar(@meal_recipes)
    
    @servings_left = @meal_recipes.size
    sum = 1.0
    @meal_recipes.each {|recipe| sum += recipe.cooktime}
    @average_cook_time = sum / @servings_left
  end
  
end
