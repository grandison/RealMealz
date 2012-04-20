class UsersIngredient < ActiveRecord::Base
  belongs_to :user
  belongs_to :ingredient
  
  #-------------------
  # This is needed for JSON conversions
  def ingredient_name
    return ingredient.name
  end
  
end
