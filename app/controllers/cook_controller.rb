class CookController < ApplicationController

  skip_before_filter :require_super_admin
  before_filter :require_user

  def cook
    # Everything will be rendered in cells
    @meals_empty = current_user.kitchen.meals.where(:my_meals => true).empty?
  end
  
  def done_cooking
#    current_user.kitchen.remove_recipe_and_ingredients(params[:recipe_id])
    redirect_to :cook
  end
  
end
