class Balance < ActiveRecord::Base
  has_many :users
  
  
#################################################################
## Returns the food balance of a RECIPE or a KITCHEN so you can create pie chart 
## Usage 1, for recipe:
##    r = Recipe.find_by_id(20)
##    @food_balance = Balance.get_food_balance(r.ingredients_recipes)
## Usage 2, for kitchen:
##    @food_balance = Balance.get_food_balance(current_user.kitchen.ingredients_kitchens)
##
  
  def self.get_food_balance(ingredients_link_table)
    protein = Unit.new("0 cup")
    vegetable = Unit.new("0 cup")
    starch = Unit.new("0 cup")
    category = nil

    
    ingredients_link_table.map {|ik|
      if !ik.ingredient.nil?
        category = ik.ingredient.get_balance_category # figure out whether it is protein, veg or fruit
      end
      if !category.nil?
        volume = Unit.new("0 cup")
        ## Set the volume variable
        if !ik.weight.nil? and !ik.unit.nil? # Have weight and unit, add it.
          volume = Unit.new("#{ik.weight.to_s} #{ik.unit}").convert_to_volume
        elsif !ik.weight.nil? and ik.unit.nil? #Have weight but no unit, assume to add weight as cup unit
          volume = Unit.new("#{ik.weight.to_s} cup")
        else  # No weight or unit given.. assume to add one cup
          volume = Unit.new("1 cup")
        end
        ## Add that volume to the right category.
        if category == :protein
          protein += volume
        elsif category == :vegetable or category == :fruit
          vegetable += volume
        elsif category == :starch
          starch += volume
        end
      end
      }
    return {:protein => protein.get_scalar, :veg => vegetable.get_scalar, :starch => starch.get_scalar}  
  end
  
  def self.create_default_balance(user_id)
     return Balance.create!(:veg => 50, :grain => 25, :protein => 25)
  end  
  
end
