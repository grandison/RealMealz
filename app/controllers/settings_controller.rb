class SettingsController < ApplicationController

  skip_before_filter :require_super_admin
  before_filter :require_user

  autocomplete :ingredient, :name, :display_value => :name

  #---------------------------------
  def settings
    @allergy_checkbox = params[:allergy_checkbox] 
    @user_allergy_list = current_user.get_basic_allergy_list
    @kitchen_user_names = current_user.kitchen.users.map {|u| u.first}
    @food_balance = Balance.get_kitchen_balance(current_user.kitchen)
    @target_food_balance = current_user.get_target_food_balance
    @exclude_items = current_user.get_exclude_list
    @background_recipe = Recipe.random_background_image
  end

  #---------------------------------
  def add_like_item
    update_like_avoid_item(:like => true)
  end

  #---------------------------------
  def remove_like_item
    update_like_avoid_item(:like => false)
  end

  #---------------------------------
  def add_avoid_item
    update_like_avoid_item(:avoid => true)
  end

  #---------------------------------
  def remove_avoid_item
    update_like_avoid_item(:avoid => false)
  end


  #---------------------------------
  def add_exclude_item
    update_exclude_item(:exclude => true)
  end

  #---------------------------------
  def remove_exclude_item
    update_exclude_item(:exclude => false)
  end

  #---------------------------------
  def save_user
    @allergy_checkbox = params[:allergy_checkbox] 
    current_user.update_basic_allergy_list(params[:allergy_checkbox])
    redirect_to '/settings'
  end


  #################
  private
  #################

  #---------------------------------
  # like and avoid are per user so are in the users_ingredients table
  def update_like_avoid_item(like_avoid)
    name_or_id = params[:item][:ingredient_id].to_i
    if name_or_id == 0
      name_or_id = params[:item][:name]
    end
    ui = current_user.update_users_ingredients(name_or_id, like_avoid)

    if params[:render] == 'added'
      render :json => {:item_id => "ui#{ui.id}", :ingredient_name => ui.ingredient.name, :ingredient_id => ui.ingredient.id}
    else
      render :nothing => true
    end
  end

  #---------------------------------
  # Exclude are items not to show on the shopping list. It is by kitchen so in the ingredients_kitchens table
  def update_exclude_item(attributes)
    name_or_id = params[:item][:ingredient_id].to_i
    if name_or_id == 0
      name_or_id = params[:item][:name]
    end
    ik = current_user.kitchen.update_ingredients_kitchens(name_or_id, attributes)

    if params[:render] == 'added'
      render :json => {:item_id => "ik#{ik.id}", :ingredient_name => ik.ingredient.name, :ingredient_id => ik.ingredient.id}
    elsif attributes[:exclude]
      render :partial => 'exclude_item', :locals => {:ingredient => ik.ingredient}
    else
      render :nothing => true
    end
  end

end
