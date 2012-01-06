class MealsCell < Cell::Rails

  def meals_list(current_user, show_plus, show_servings)
    meals = current_user.kitchen.get_sorted_my_meals
    render :locals => {:my_meals => meals, :show_plus => show_plus, :show_servings => show_servings, :kitchen => current_user.kitchen}
  end

end
