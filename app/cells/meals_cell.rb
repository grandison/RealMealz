class MealsCell < Cell::Rails

  def meals_list(current_user, show_plus, show_servings)
    meals = current_user.kitchen.get_sorted_my_meals
    meal_balance = Balance.get_kitchen_current_balance(current_user.kitchen)
    render :locals => {:my_meals => meals, :show_plus => show_plus, :show_servings => show_servings, 
      :kitchen => current_user.kitchen, :meal_balance => meal_balance}
  end

end
