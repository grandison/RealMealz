class CookController < ApplicationController

  skip_before_filter :require_super_admin
  before_filter :require_user

  def cook
    # Everything will be rendered in cells
    @meals_empty = current_user.kitchen.meals.where(:my_meals => true).empty?
    @recipe_id = params[:recipe_id]
  end
  
  def done_cooking
    recipe = Recipe.find(params[:recipe_id])
    MealHistory.create!(:recipe_id => recipe.id, :kitchen_id => current_user.kitchen.id, :eaten_on => Date.today, 
      :balance_vegetable => recipe.balance_vegetable,
      :balance_starch => recipe.balance_starch,
      :balance_protein => recipe.balance_starch)
    if params['render'] == 'nothing'
      render :nothing => true
    else
      redirect_to :cook
    end
  end
  
end
