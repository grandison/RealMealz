class DiscoverController < ApplicationController
  
  skip_before_filter :require_super_admin
  before_filter :require_user
  
  #------------------------- 
  def discover
    @recipes = get_new_recipes([], {})
    @avoid_items = current_user.get_like_avoid_list(:avoid)
    setup_discover
  end

  #------------------------- 
  def recipe_shown
    current_user.kitchen.increment_seen_count(params[:recipe_id])
    render :nothing => true
  end

  #------------------------- 
  def next_recipes
    if params[:recipe_ids].blank?
      recipe_ids_shown = []
    else
      recipe_ids_shown = params[:recipe_ids].split(',').map {|s| s.to_i} 
    end
    
    if params[:no_changes]
      @recipes = []
      5.times do 
        recipe_id = session[:next_recipe_ids].shift
        break if recipe_id.nil?
        @recipes << Recipe.find(recipe_id) #TO-DO deal with no more recipes
      end
    else
      @recipes = get_new_recipes(recipe_ids_shown, fix_booleans(params[:filters]))
    end
    setup_discover
    render :partial => 'recipes', :locals => {:recipes => @recipes, :show_big => (params[:show_big] == 'true')}
  end
  
  #-----------
  def update_pantry
    fix_booleans(params)
    current_user.kitchen.add_or_update_pantry_ingredient(params[:ingredient_id], params[:checked])
    render :nothing => true
  end
  
  #------------------------- 
  def meal_update
    # Pass nil if parameter not passed so it doesn't change
    my_meals = nil
    my_meals = (params[:my_meals] == 'true') if params[:my_meals]
    starred = nil
    starred = (params[:starred] == 'true') if params[:starred]
    
    current_user.kitchen.update_meals(params[:recipe_id], my_meals, starred) 
    unless params[:op] == 'add'
      skip_check_points
    end
    render :nothing => true
  end
  
  #------------------------- 
  def new_cooking_skills
  end

  ##############
  private
  ##############
  
  #------------------------- 
  def get_new_recipes(recipe_ids_shown, filters)
    # Sort all recipes by standard criteria
    recipe_ids = current_user.get_favorite_recipes(recipe_ids_shown, filters)
    
    # Only send 5 recipes but save the ids of the rest
    num_to_send = (recipe_ids.length < 5)? recipe_ids.length : 5
    session[:next_recipe_ids] = recipe_ids[num_to_send..-1]
    return Recipe.where(:id => recipe_ids[0..num_to_send - 1])
  end
  
  #------------------------- 
  # This is the information needed to render the recipe. Avoid not needed since these only appear once in the Avoid list
  def setup_discover
    return if @recipes.blank?
    
    @recipes.each do |recipe|
      recipe.setup_recipe
    end
    @have_ingredients = current_user.kitchen.have_ingredients
    @starred_ids = current_user.kitchen.starred_meal_ingredient_ids 
    @my_meals_ids = current_user.kitchen.my_meals_recipe_ids
  end
  
end