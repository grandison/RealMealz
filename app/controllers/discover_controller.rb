class DiscoverController < ApplicationController
  
  skip_before_filter :require_super_admin
  before_filter :require_user
  
  #------------------------- 
  def discover
    # MD Apr-2012 If present, use ID and ignore name. But ID paramenter could also be the name
    if params[:id] || params[:name]
      name = CGI.unescape(params[:name]) if params[:name]
      id = CGI.unescape(params[:id]) if params[:id]
      @recipes = current_user.kitchen.find_recipe(id || name)
      if @recipes.blank?
        flash[:error] = "Recipe not found"
      end  
    end  
    
    if @recipes.blank?
      @recipes = get_new_recipes([], {})
    end
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
        recipe_id = session[:next_recipe_ids] && session[:next_recipe_ids].shift
        break if recipe_id.nil?
        @recipes << Recipe.find(recipe_id) #TO-DO deal with no more recipes
      end
    else
      @recipes = get_new_recipes(recipe_ids_shown, fix_booleans(params[:filters]))
    end
    setup_discover
    
    if params[:render] == 'xml'
      render :xml => @recipes.map {|recipe| recipe.meal_hash}
    elsif params[:render] == 'json'
      render :json => @recipes.map {|recipe| recipe.meal_hash}
    else
      render :partial => 'recipes', :locals => {:recipes => @recipes, :show_big => (params[:show_big] == 'true')}
    end  
  end
  
 
  
  
  #------------------------- 
  # API call for Android version. Just return 1 recipe at a time
  def next_recipe
    recipe_id = session[:next_recipe_ids] && session[:next_recipe_ids].shift
    if recipe_id.present?
      recipe = Recipe.find(recipe_id)
    else
      recipe = get_new_recipes([], {}, num_to_send = 1)[0]
    end  
    meal = recipe.meal_hash    
    
    if params[:render] == 'xml'
      render :xml => meal
    else
      render :json => meal
    end
  end

  #-----------
  def update_pantry
    fix_booleans(params)
    current_user.kitchen.add_or_update_pantry_ingredient(params[:ingredient_id], params[:checked])
    render :nothing => true
  end
  
  #------------------------- 
  def meal_update
    fix_booleans(params)
    current_user.kitchen.update_meals(params[:recipe_id], params[:my_meals], params[:starred]) 
    render :nothing => true
  end
  
  #-------------------------
  def cook_now
    current_user.kitchen.update_meals(params[:recipe_id], my_meals = true, starred = nil)
    redirect_to "/cook?recipe_id=#{params[:recipe_id]}"
  end
  
  #------------------------- 
  def new_cooking_skills
  end
  
  ##############
  private
  ##############
  
  #------------------------- 
  def get_new_recipes(recipe_ids_shown, filters, max_num_to_send = 5)
    # Sort all recipes by standard criteria
    recipe_ids = current_user.get_favorite_recipes(recipe_ids_shown, filters)
    
    # Only send some of the recipes but save the ids of the rest
    num_to_send = (recipe_ids.length < max_num_to_send)? recipe_ids.length : max_num_to_send
    session[:next_recipe_ids] = recipe_ids[num_to_send..-1]
    show_ids = recipe_ids[0..num_to_send - 1]
    return Recipe.where(:id => show_ids).sort { |r1, r2| show_ids.index(r1.id) <=> show_ids.index(r2.id) } # Get the recipes and sort in correct order
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