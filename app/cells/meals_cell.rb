class MealsCell < Cell::Rails

  def meals_list(current_user, show_plus)
    meals = current_user.kitchen.get_sorted_my_meals
    render :locals => {:my_meals => meals, :show_plus => show_plus}
  end

end
