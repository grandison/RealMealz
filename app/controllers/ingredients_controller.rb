class IngredientsController < ApplicationController
  skip_before_filter :require_super_admin
  before_filter :require_user
  
  #------------------------- 
  def combine_ingredients
    if params[:checked].nil? || params[:checked][:from].nil? || params[:checked][:to].nil?
      flash[:notice] = "Please select both a From and a To ingredient to combine"
    else
      ingr_from = Ingredient.find(params[:checked][:from])
      ingr_to = Ingredient.find(params[:checked][:to])

      if current_user.role != 'super_admin' && 
        (ingr_from.kitchen_id != current_user.kitchen_id ||
        ingr_to.kitchen_id != current_user.kitchen_id)
        flash[:notice] = "Security violation!"
      else
        Ingredient.combine_ingredients(ingr_from, ingr_to)
        flash[:notice] = "'#{ingr_from.name}' combined into '#{ingr_to.name}'"
      end    
    end
    redirect_to "/ingredients"
  end

  #------------------------- 
  def index
    if current_user.role == 'super_admin'
      @ingredients = Ingredient.all.sort_by {|i| i.name}
    else
      @ingredients = Ingredient.where(:kitchen_id => current_user.kitchen_id).sort_by {|i| i.name}
    end
        
    respond_to do |format|
      format.html #"index" 
      format.xml  { render :xml => @ingredients }
    end
  end

  #------------------------- 
  # Placeholder so routes resource :ingredients doesn't mess up authorization tests
  def show
    render :nothing => true
  end

  #------------------------- 
  def new
    @ingredient = Ingredient.new
    if current_user.role != 'super_admin'
      @ingredient.kitchen_id = current_user.kitchen_id  
    end

    respond_to do |format|
      format.html #{ render "ingredient_form" }
      format.xml  { render :xml => @ingredient }
    end
  end

  #------------------------- 
  def edit
    @ingredient = recipe_find_by_id_with_user_check(params[:id])
  end

  #------------------------- 
  def edit_or_create_by_name
    @ingredient = recipe_find_by_name_with_user_check(params[:ingredient_name])
    if @ingredient.nil?
      @ingredient.new(:name => params[:ingredient_name])
    else
    end
    render :partial => "ingredient_form"
  end

  #------------------------- 
  def create
    @ingredient = Ingredient.new(params[:ingredient])
    if current_user.role != 'super_admin'
      @ingredient.kitchen_id = current_user.kitchen_id  
    end

    respond_to do |format|
      if @ingredient.save
        format.html { redirect_to('/ingredients', :notice => 'Ingredient was successfully created.') }
        format.xml  { render :xml => @ingredient, :status => :created, :location => @ingredient }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ingredient.errors, :status => :unprocessable_entity }
      end
    end
  end

  #------------------------- 
  def update
    @ingredient = recipe_find_by_id_with_user_check(params[:id])

    respond_to do |format|
      if @ingredient.update_attributes(params[:ingredient])
        format.html { redirect_to('/ingredients', :notice => 'Ingredient was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ingredient.errors, :status => :unprocessable_entity }
      end
    end
  end

  #------------------------- 
  # Placeholder so routes resource :ingredients doesn't mess up authorization tests
  def destroy
    render :nothing => true
  end
  
  ###############
  private
  ###############

  #------------------------- 
  def recipe_find_by_id_with_user_check(id)
    if current_user.role == 'super_admin'
      @ingredient = Ingredient.find(id)
    else
      # Find this manually because the relation between kitchens and unique ingredients is not setup
      # Since ingredients_kitchens is for panty ingredients     
      @ingredient = Ingredient.where(:kitchen_id => current_user.kitchen_id, :id => id).first
    end
  end   

  #------------------------- 
  def recipe_find_by_name_with_user_check(name)
    if current_user.role == 'super_admin'
      kitchen_id = 0
    else
      kitchen_id = current_user.kitchen_id
    end
    @ingredient = Ingredient.find_or_create_by_name(name, kitchen_id)
  end   
  
end
