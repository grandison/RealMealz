class IngredientsKitchen < ActiveRecord::Base
  belongs_to :kitchen
  belongs_to :ingredient
  validates_presence_of :kitchen, :ingredient
  require 'weight_and_unit'
  
  #-------------------
  def name
    weight_and_unit_name
  end

  #-------------------
  def weight_and_units
    weight_and_unit_name(units_only = true)
  end
  
  #-------------------
  # This is needed for JSON conversions
  def ingredient_name
    return ingredient.name
  end
  
end
