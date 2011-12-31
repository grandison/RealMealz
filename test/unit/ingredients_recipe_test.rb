require 'test_helper'

class IngredientsRecipeTest < ActiveSupport::TestCase
 
  def setup
  end
  
  test "weight display" do
    assert_equal '2 lbs', IngredientsRecipe.create(:weight => 2, :unit => 'lbs').name
    assert_equal '0.4 lbs', IngredientsRecipe.create(:weight => 0.4, :unit => 'lbs').name
    assert_equal '1/4 cup', IngredientsRecipe.create(:weight => 1/4, :unit => 'cup').name
    assert_equal '1/2 cup', IngredientsRecipe.create(:weight => 1/2, :unit => 'cup').name
    assert_equal '3/4 cup', IngredientsRecipe.create(:weight => 3/4, :unit => 'cup').name
    assert_equal '1/3 cup', IngredientsRecipe.create(:weight => 1/3, :unit => 'cup').name
    assert_equal '2/3 tsp', IngredientsRecipe.create(:weight => 2/3, :unit => 'tsp').name
  end  

  test "name" do
    i1 = Ingredient.create!(:name => "Wheat", :other_names => "|wheat|")
    i2 = Ingredient.create!(:name => "Egg", :other_names => "|egg|eggs|")
    i3 = Ingredient.create!(:name => "Celery", :other_names => "|celery|", :whole_unit => 'stalk')
    recipe = Recipe.create!(:name => "Test recipe")
    ir1 = IngredientsRecipe.create(:weight => 0.4, :unit => 'lbs', :ingredient_id => i1.id, :recipe_id => recipe.id)
    ir2 = IngredientsRecipe.create(:weight => 2, :unit => 'lbs', :ingredient_id => i1.id, :recipe_id => recipe.id)
    ir3 = IngredientsRecipe.create(:weight => 1, :unit => 'whole', :ingredient_id => i2.id, :recipe_id => recipe.id)
    ir4 = IngredientsRecipe.create(:weight => 5, :unit => 'whole', :ingredient_id => i2.id, :recipe_id => recipe.id)
    ir5 = IngredientsRecipe.create(:weight => 5, :unit => 'whole', :ingredient_id => i2.id, :recipe_id => recipe.id)
    
    assert_equal "0.4 lbs Wheat", ir1.name
    assert_equal "2 lbs Wheat", ir2.name
    assert_equal "1 Egg", ir3.name
    assert_equal "5 Eggs", ir4.name
  end

end
