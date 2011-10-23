require 'test_helper'

class IngredientsRecipeTest < ActiveSupport::TestCase
  ###########################################################
  ## Tests method:
  ##  get_weight_units
  test "get_weight_units" do
    r = Recipe.find_by_id(503)
    assert_equal Unit.new("1.0"), r.ingredients_recipes[1].get_weight_units
    assert_equal Unit.new("3 clove"),r.ingredients_recipes[2].get_weight_units
  end
end
