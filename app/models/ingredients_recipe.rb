class IngredientsRecipe < ActiveRecord::Base
  belongs_to :recipe, :include => :ingredients
  belongs_to :ingredient
  
  ####################################################################################
  def count
    return length
  end

  ####################################################################################
  ## returns the weight and unit combined into a Unit class object
  ## checks to make sure nils are handled
  ## Usage: Recipe.ingredients_recipes[2].get_weight_units
  def get_weight_units
    if !weight.nil? and !unit.nil?
      return Unit.new(weight.to_s + unit.to_s)
    elsif !weight.nil? and unit.nil?
      return Unit.new(weight)
    else #if weight.nil? and !unit.nil?
      return nil
    end
  end
    
end
