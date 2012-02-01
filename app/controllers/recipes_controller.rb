class RecipesController < ApplicationController
  skip_before_filter :require_super_admin
  before_filter :require_user
  
  #------------------------- 
  def recipe_setup
    @recipe = Recipe.find(params[:recipe_id])
    @recipe.setup_recipe(current_user.kitchen.default_servings)
    render :partial => 'recipe_display'
  end
  
  #------------------------- 
  def create_from_url
    recipe = Recipe.create_from_html(params[:url])
    if recipe.nil?
      flash[:notice] = 'Website not supported'
      redirect_to :recipes
      return
    end
    
    recipe.kitchen_id = current_user.kitchen_id
    recipe.save!
    params[:id] = recipe.id
    edit
    render :edit
  end

  #------------------------- 
  def update_servings
    current_user.kitchen.update_attributes!(:default_servings => params[:new_servings])
    recipe = Recipe.find(params[:recipe_id])
    recipe.adjust_servings(params[:new_servings].to_i)
    render :partial => "recipe_ingredient_list", :locals => {:ingredients_recipes => recipe.ingredients_recipes}
  end

  #------------------------- 
  def reprocess
    recipe = Recipe.find(params[:recipe_id])
    recipe.ingredient_list = params[:ingredient_list]
    Ingredient.reset_cache # In case they changed the ingredient list
    recipe.process_ingredient_list
    recipe.ingredient_list = nil # force recipe to regenerate list
    render :text => recipe.ingredient_list
  end

  #------------------------- 
  def index
    if current_user.role == 'super_admin'
      @recipes = Recipe.all
    else
      @recipes = current_user.kitchen.recipes
    end
    # Sort by reverse updated_at. Need to deal with nulls
    null_time = DateTime.new(2008, 1, 1)
    @recipes.sort!{|r1, r2| (r2.updated_at || null_time) <=> (r1.updated_at || null_time)}

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @recipes }
    end
  end

  #------------------------- 
  def new
    @recipe = Recipe.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @recipe }
    end
  end
  
  #------------------------- 
  # Placeholder so routes resource :recipes doesn't mess up authorization tests
  def show
    render :nothing => true
  end

  #------------------------- 
  def edit
    @recipe = recipe_find_with_user_check(params[:id])
  end

  #------------------------- 
  def create
    @recipe = Recipe.create(params[:recipe])
    @recipe.kitchen_id = current_user.kitchen_id
    @recipe.save! #Save in case uploaded picture
    @recipe.process_recipe

    respond_to do |format|
      if @recipe.save
        format.html { redirect_to('/recipes', :notice => 'Recipe was successfully created.') }
        format.xml  { render :xml => @recipe, :status => :created, :location => @recipe }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @recipe.errors, :status => :unprocessable_entity }
      end
    end
  end

  #------------------------- 
  def update
    @recipe = recipe_find_with_user_check(params[:id])

    respond_to do |format|
      if @recipe.update_attributes(params[:recipe]) && @recipe.process_recipe
        format.html { redirect_to('/recipes', :notice => 'Recipe was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @recipe.errors, :status => :unprocessable_entity }
      end
    end
  end

  #------------------------- 
  def destroy
    @recipe = recipe_find_with_user_check(params[:id])
    @recipe.destroy

    respond_to do |format|
      format.html { redirect_to(recipes_url) }
      format.xml  { head :ok }
    end
  end
  
  ###############
  private
  ###############

  #------------------------- 
  def recipe_find_with_user_check(id)
    if current_user.role == 'super_admin'
      @recipe = Recipe.find(id)
    else
      @recipe = current_user.kitchen.recipes.find(id)
    end
  end   
end
