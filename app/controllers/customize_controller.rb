class CustomizeController < ApplicationController

  skip_before_filter :require_super_admin
  before_filter :require_user
  
  autocomplete :ingredient, :name, :display_value => :display_name
  
  def index
    @allergy_checkbox = params[:allergy_checkbox] 
    @user_allergy_list = current_user.get_basic_allergy_list
    @kitchen_user_names = current_user.kitchen.users.map {|u| u.first}
    @food_balance = Balance.get_food_balance(current_user.kitchen.ingredients_kitchens)
    @target_food_balance = current_user.get_target_food_balance
    @like = current_user.ingredients
    @new_like = ''
  end
  
  def add_like_item
    ingredient = current_user.add_like_item(params[:new_item_name])
    render :partial => 'like_item', :locals => {:ingredient => ingredient}
  end
  
  def remove_like_item
    current_user.remove_like_item(params[:remove_item_id])
    render :nothing => true
  end

    
  def save_user
    @allergy_checkbox = params[:allergy_checkbox] 
    current_user.update_basic_allergy_list(params[:allergy_checkbox])
    
    ## call both cleanup and generate in case user has changed allergy settings
    current_user.clean_up_user_recipes
    current_user.generate_user_recipes
    redirect_to '/customize/index'
  end
  
  def kitchen
    @kitchen_user_names = current_user.kitchen.users.map {|u| u.first}
    @default_meal_days = day_check_box_info(current_user.kitchen.default_meal_days)
    @default_servings = current_user.kitchen.default_servings
  end
  
  def save_food_balance
    current_user.update_target_food_balance(params[:newveg], params[:newstarch], params[:newprotein])
    redirect_to '/customize'
  end
  
  def save_kitchen
    default_servings = params[:default_servings]
    current_user.kitchen.update_default_servings(default_servings)
    @days = params[:days].to_s
    current_user.kitchen.set_default_meal_days(@days)
    redirect_to '/customize/kitchen'
  end
  
  #################
  private
  #################
  
  def day_check_box_info(default_meal_days)
    meal_days = default_meal_days
    if meal_days.blank?
      meal_days = Kitchen::DEFAULT_MEAL_DAYS
    end
    return_array = []
    [1, 2, 3, 4, 5, 6, 0].each do |day|
      return_array << {:name => Date::DAYNAMES[day], :value => day, :selected => meal_days.include?(day.to_s[0])}
    end
    return return_array
  end
  
  
end
