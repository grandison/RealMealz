class ShopController < ApplicationController
  
  skip_before_filter :require_super_admin
  before_filter :require_user
  
  autocomplete :ingredient, :name, :display_value => :name
  
  def shop_list
    @item_list = current_user.kitchen.get_sorted_shopping_items if params[:render].nil?
    render_list
  end

  def pantry_list
    @item_list = current_user.kitchen.get_sorted_pantry_items if params[:render].nil?
    render_list
  end
  
  def add_item
    name = params[:item][:name]
    params[:item].delete(:name)
    ik = current_user.kitchen.add_new_pantry_item(name, params[:item].merge(:have => true))
    if params[:render] == 'added'
      render :json => {:item_id => ik.id, :ingredient_name => ik.ingredient.name, :ingredient_id => ik.ingredient.id}
    else
      render_list
    end
  end
  
  def remove_from_shopping_list
    current_user.kitchen.remove_from_shopping_list(params[:id])
    render :nothing => true
  end
  
  def update
    fix_booleans(params)
    current_user.kitchen.update_shop_list(params[:id], params[:value], params[:shop])
    skip_check_points if params[:shop] == 'true' && params[:value] == 'false'
    render :nothing => true
  end

  def update_item
    # Fix for Javascript
    [:id, :pantry_id, :ingredient_id, :name].each do |p|
      params[:item][p] = nil if params[:item][p] == 'undefined'
    end
      
    ## TO-DO Move below to model
    pantry_id = params[:item][:pantry_id] || params[:item][:id] #Support old and new params
    if !pantry_id.nil? 
      ik =  current_user.kitchen.ingredients_kitchens.find_by_id(pantry_id)
    elsif !params[:item][:ingredient_id].nil?
      ik = current_user.kitchen.ingredients_kitchens.find_by_ingredient_id(params[:item][:ingredient_id])
    else
      name = params[:item][:name].strip.downcase
      ingredient = Ingredient.where('other_names LIKE ? and (kitchen_id IS NULL or kitchen_id = ?)', "%|#{name}|%", current_user.kitchen_id).first
      ik = current_user.kitchen.ingredients_kitchens.find_by_ingredient_id(ingredient)
    end
    
    ##TODO Disable updating of name for now. Only let them change name
    # if item is special in their kitchen. Otherwise, need to see if name is already an ingredient and
    # point to that. If not, then copy as special
    params[:item].delete(:name)
    params[:item].delete(:id)
    params[:item].delete(:pantry_id)
    params[:item].delete(:ingredient_id)
    ik.update_attributes!(params[:item])
    
    if params[:render] == 'none'
      render :nothing => true
    else
      pantry_list
    end
  end
  
  def email_shopping_list
    ShopListMailer.shop_list_email(current_user, current_user.kitchen.get_sorted_shopping_items).deliver!
    flash.now[:notice] = "Shopping list emailed to #{current_user.email}"
    render :nothing => true
  end

  def done_shopping
    current_user.kitchen.done_shopping
    render_list(just_shop_list = true)
  end
  
  def clear_shopping_list
    current_user.kitchen.clear_shopping_list
    render_list(just_shop_list = true)
  end

  def add_recipe_ingredients
    current_user.kitchen.add_recipe_ingredients_to_shopping_list(params[:recipe_id])
    
    render_list(just_shop_list = true)
  end
  
  def update_default_servings
    current_user.kitchen.update_attributes!(:default_servings => params[:kitchen][:default_servings])
    render :nothing => true
  end

  def highlight_ingredients
    cached_ingredients = Rails.cache.read("recipe_#{params[:recipe_id]}")

    if cached_ingredients.present?
      @ingredients_kitchen_ids = cached_ingredients
    else
      ingredient_ids = Recipe.find(params[:recipe_id]).ingredient_ids

      @ingredients_kitchen_ids = current_user.kitchen.ingredients_kitchens.
        where("ingredient_id IN (?)", ingredient_ids).map(&:id)

      Rails.cache.write("recipe_#{params[:recipe_id]}", @ingredients_kitchen_ids, :expires_in => 1.days)
    end
  end
  
  ##############
  private
  ##############
  
  def render_list(just_shop_list = false)
    if @item_list.nil? && !params[:render].nil?
      @item_list = current_user.kitchen.get_sorted_shopping_items
    end
    
    if params[:render] == 'json'
      render :json => @item_list.to_json(:methods => :ingredient_name)
    elsif params[:render] == 'xml'
      render :xml => @item_list.to_xml(:methods => :ingredient_name)
    elsif just_shop_list
      # @item_list is generated in render_cell
      render :inline => render_cell(:shop, :shop_list, current_user, mobile_request?)
    else
      @kitchen = current_user.kitchen
      render :shop
    end
  end

end
