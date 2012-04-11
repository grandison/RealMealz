# This controller is just for an API to the mobile version.
# Creating and rendering of meals is handled by meals_cell.rb

class MealsController < ApplicationController
  skip_before_filter :require_super_admin
  before_filter :require_user
  
  def my_meals
    meals = []
    current_user.kitchen.get_sorted_my_meals.each do |meal|
      next if meal.recipe_id.nil?
      meals << meal.recipe.meal_hash
    end

    if params[:render] == 'xml'
      render :xml => meals
    else
      render :json => meals
    end
  end
end