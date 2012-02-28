class CookController < ApplicationController

  skip_before_filter :require_super_admin
  before_filter :require_user

  def cook
    # Everything will be rendered in cells
    @meals_empty = current_user.kitchen.meals.where(:my_meals => true).empty?
    @recipe_id = params[:recipe_id]
  end
  
  def done_cooking
    redirect_to :cook
  end
  
end
