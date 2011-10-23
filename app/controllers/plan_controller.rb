class PlanController < ApplicationController

  skip_before_filter :require_super_admin
  before_filter :require_user

  def plan
    current_user.generate_user_recipes
    @box_recipes = current_user.recipes
    @next_recipes = current_user.kitchen.get_sorted_meal_recipes
  end

  def update_meal_order
    current_user.kitchen.update_order(params[:order], :meal_order)
    render :nothing => true
  end
  
  def add_course
    meal = Meal.find_or_create_meal(params[:date], :dinner, User.current_user.kitchen_id)
    course = meal.add_course
    course.add_recipe_list
    render :partial => 'course', :locals => {:course => course}
  end

  def add_recipe_to_meals
    meal = Meal.find_or_create_meal(Date.today.to_s, :dinner, User.current_user.kitchen_id)
    course = meal.add_course(params[:recipe_id])
    render :nothing => true
  end

  def remove_recipe_from_meals
    Course.delete_course_by_recipe(params[:recipe_id])
    render :nothing => true
  end

  def delete_course
    Course.destroy(params[:course_id])
    render :inline => "course_id_#{params[:course_id]}"
  end
  
  def add_courses_to_shopping_list
    @start_date = params[:start_date] || Date.today.to_s
    @end_date = params[:end_date] || (Date.today + 7).to_s
    begin
      start_date = Date.parse(@start_date)
      end_date = Date.parse(@end_date)
    rescue
      flash[:error] = "Date Format ERROR, Please re-enter"
      redirect_to '/plan'
    end
    
    ingr_list = current_user.kitchen.planned_meal_shopping_list(end_date, start_date) 
    current_user.kitchen.add_recipes_to_pantry_and_cart(ingr_list)
    redirect_to '/shop/shop_list'
  end
  
end