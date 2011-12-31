class Balance < ActiveRecord::Base
  has_many :users

  def self.get_kitchen_balance(kitchen)
    balance = {:protein => 0, :vegetable => 0, :starch => 0} 
    kitchen.meals.each do |meal|
      if meal.recipe.nil?
        meal.delete
        next
      end
      recipe_balance = meal.recipe.food_balance
      balance[:protein] += recipe_balance[:protein]
      balance[:vegetable] += recipe_balance[:vegetable]
      balance[:starch] += recipe_balance[:starch]
    end
    return balance
  end

  def self.create_default_balance(user_id)
    return Balance.create!(:veg => 50, :grain => 25, :protein => 25)
  end  

end
