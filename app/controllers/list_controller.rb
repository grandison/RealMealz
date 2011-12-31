class ListController < ApplicationController

  skip_before_filter :require_super_admin
  before_filter :require_user
  
  #------------------------- 
  def table_list
    if params[:name].nil?
      render :inline => 'No table name specified'
      return
    end
    
    table_sym = params[:name].to_sym
    if [:allergies, :appliances, :appliances_kitchens, :categories, :categories_ingredients, :ingredients, 
      :ingredients_kitchens, :ingredients_recipes, :kitchens, :meal_types, :meals, :personalities, :points, 
      :products, :recipes, :recipes_personalities, :sliding_scales, :sort_orders, :stores, :users_allergies, 
      :users_categories, :users_personalities, :users_points, :users_recipes, :users_sliding_scales].include?(table_sym)
      table = table_sym.to_s.classify.constantize
      
      if table_sym == :kitchens
        list = Kitchen.find_by_id(current_user.kitchen_id)
      elsif table_sym == :ingredients
        list = Ingredient.where('kitchen_id IS NULL or kitchen_id = ?', current_user.kitchen_id)
      elsif table_sym == :recipes
        list = Recipe.where('public = ? or kitchen_id = ?', true, current_user.kitchen_id)
      else
        if table.column_names.include?('user_id')
          list = table.where(:user_id => current_user.id)
        elsif table.column_names.include?('kitchen_id')
          list = table.where(:kitchen_id => current_user.kitchen_id)
        else
          list = table.all
        end
      end
      
      if params[:render] == 'json'
        render :json => list
      else
        render :xml => list
      end
    else
      render :inline => "Unknown table #{params[:name]}"
    end
  end

end
