class RecipesController < ApplicationController
  
  active_scaffold :recipes do |config|
    config.list.columns = [:name, :picture, :approved, :preptime, :cooktime, :intro, :servings, :prepsteps, :cooksteps, :tags, :skills]
    config.columns = [:name, :picture, :approved, :servings, :intro, :original, :tags, :source, :preptime, :cooktime, 
      :ingredients_recipes, :recipes_personalities]
    config.columns[:ingredients_recipes].label = "Ingredients"
    config.columns[:recipes_personalities].label = "Personalities"
    config.columns[:original].options = {:cols => 130, :rows => 15}    
  end

  #------------------------- 
  def recipe_setup
    @recipe = Recipe.find(params[:recipe_id])
    @recipe.setup_recipe
    render :partial => 'recipe_display'
  end
  
  #------------------------- 
  def move_ingredient
    ik = IngredientsKitchen.find_or_create_by_ingredient_id_and_kitchen_id(:ingredient_id => params[:ingredient_id], :kitchen_id => current_user.kitchen.id)
    ik.update_attributes!(:needed => (params[:where] == 'needed'))
    render :nothing => true
  end
  

  #------------------------- 
  def process_ingredients
    ## still need to figure out how to pass the picture back using paperclip.
    @pic_name = params[:picture] || ''
    
    @recipe_name = params[:recipe_name] || ''
    @intro = params[:intro] || ''
    @ingredients = params[:ingredients] || ''
    @prepsteps = params[:prepsteps] || ''
    @cooksteps = params[:cooksteps] || ''
    @servings = params[:servings] || ''
    @preptime = params[:preptime] || ''
    @cooktime = params[:cooktime] || ''
    @source = params[:source] || ''
    @tags = params[:tags] || ''
    @skills = params[:skills] || ''
    
	  original = @recipe_name + "\n**intro**\n" + @intro + "\n**ingredients**\n" + @ingredients + "\n**prep**\n" + @prepsteps + "\n**cook**\n" + @cooksteps + "\n**serves**\n" + @servings.to_s + "\n**preptime**\n" + @preptime.to_s + "\n**cooktime**\n" + @cooktime.to_s + "\n**source**\n" + @source.to_s + "\n**skills**\n" + @skills + "\n**tags**\n" + @tags.to_s
	  
	  ingredient_array = Array.new
	  ingredient_array = Recipe.parse_ingredients(@ingredients.split(/\n/))
	  recipe_id = Recipe.add_recipe(original , @recipe_name, @intro, ingredient_array, @prepsteps, @cooksteps, @servings, @preptime, @cooktime, @source, @tags, @skills, @pic_name,"no")
	#  Recipe.find(recipe_id).update(params[:recipe])
	  
    if request.post?
    	redirect_to "/recipes/#{recipe_id}/edit.html"
    end
  end
end
