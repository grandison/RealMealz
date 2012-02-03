# This controller is just for an API to the mobile version.
# Creating and rendering of meals is handled by meals_cell.rb

class MealsController < ApplicationController
  skip_before_filter :require_super_admin
  before_filter :require_user
  
  def my_meals
    meals = []
    current_user.kitchen.get_sorted_my_meals.each do |meal|
      next if meal.recipe_id.nil?
      
      meals << {:recipe_id => meal.recipe_id, :recipe_name => meal.recipe.name, 
        :recipe_intro => meal.recipe.intro,
        :recipe_prepsteps => meal.recipe.prepsteps, :recipe_cooksteps => meal.recipe.cooksteps,
        :recipe_source => meal.recipe.source, :recipe_source_link => meal.recipe.source_link,
        :recipe_servings => meal.recipe.servings, 
        :recipe_prep_time => meal.recipe.preptime, :recipe_cook_time => meal.recipe.cooktime,  
        :picture_thumb => meal.recipe.picture(:thumb), 
        :picture_medium =>  meal.recipe.picture(:medium),
        :ingredients => meal.recipe.ingredients_recipes.map {|ir| {:ingredient_name => ir.ingredient.name,
          :unit => ir.unit, :weight => ir.weight, :description => ir.description,
          :name_and_unit => ir.name} }
      }
    end

    if params[:render] == 'xml'
      render :xml => meals
    else
      render :json => meals
    end
  end
end