require 'test_helper'

class IngredientTest < ActiveSupport::TestCase
 
  def setup
  end
  
  #--------------
  test "unit names sorted" do
     assert_equal 'milliliters', Ingredient.unit_names.first[:alias]
     assert_equal 'g', Ingredient.unit_names.last[:alias]
  end
  
  #--------------
  test "find unit name" do
	  assert_equal "tbs", Ingredient.find_unit("2 tablespoons olive oil")
	  assert_equal "tsp", Ingredient.find_unit("1 1/4 teaspoons kosher salt")
	  assert_equal "cup", Ingredient.find_unit("2 1/2 cups button mushrooms")
  	assert_equal "oz", Ingredient.find_unit("3/4oz. ")
	  assert_equal "whole", Ingredient.find_unit("2handfuls ")
  end

  #--------------
  test "trim unit name" do
    line = "3/4oz. "
  	Ingredient.find_unit(line)
  	assert_equal "3/4", line.strip.squeeze(" ")
  	
	  line = "2 1/2 cups button mushrooms"
	  Ingredient.find_unit(line)
  	assert_equal "2 1/2 button mushrooms", line.strip.squeeze(" ")
  end

  #--------------
  test "find or create" do
    kitchen_id = 0
    ingr1 = Ingredient.find_or_create_by_name(' Wheat ', kitchen_id)
    assert_equal 'Wheat', ingr1.name

    ingr2 = Ingredient.find_or_create_by_name('wheat', kitchen_id)
    assert_equal ingr1.id, ingr2.id, 'Find ingredient just created'
  end  
  
  #--------------
  test "find smaller name" do
    kitchen_id = 0
    ingr1 = Ingredient.find_or_create_by_name('Whole wheat', kitchen_id)
    ingr2 = Ingredient.find_or_create_by_name('Wheat', kitchen_id)
    ingr3 = Ingredient.find_or_create_by_name('Wheat bread', kitchen_id)
    assert_equal "Wheat", ingr2.name
  end  
  
  #--------------
  test "sort by name length" do
    Ingredient.delete_all
    i1 = Ingredient.create!(:name => "Wheat", :other_names => "wheat")
    i2 = Ingredient.create!(:name => "Jalapeno pepper", :other_names => "jalapeno pepper|jalapeno peppers")
    i3 = Ingredient.create!(:name => "Pineapple", :other_names => "pineapple|pineapples")
    
    sorted = Ingredient.create_hash_by_name_length
    assert_equal 5,sorted.length
    assert_equal i2.id, sorted[0][:id]
    assert_equal i2.id, sorted[1][:id]
    assert_equal i3.id, sorted[2][:id]
    assert_equal i3.id, sorted[3][:id]
    assert_equal i1.id, sorted[4][:id]
    assert_equal "jalapeno peppers", sorted[0][:name]
    assert_equal "wheat", sorted[4][:name]
  end

  #--------------
  test "standardize units" do
    ir = IngredientsRecipe.create(:unit => 'pint', :weight => 0.5)
    Ingredient.standardize_unit(ir)
    assert_equal '1 cup', ir.name

    ir = IngredientsRecipe.create(:unit => 'ml', :weight => 20)
    Ingredient.standardize_unit(ir)
    assert_equal '1.35 tbs', ir.name
  end
  
  #--------------
  test "combine ingredients" do
    ingr_combine = Ingredient.create!(:name => "Jalapeno pepper", :other_names => "jalapeno pepper|jalapeno peppers")
    ingr_main = Ingredient.create!(:name => "Jalapeno", :other_names => "jalapeno|jalapenos")
    
    kitchen = Kitchen.create!(:name => "Test kitchen")
    ik = IngredientsKitchen.create!(:ingredient_id => ingr_combine.id, :kitchen_id => kitchen.id)
    recipe = Recipe.create!(:name => "Test recipe")
    ir = IngredientsRecipe.create!(:ingredient_id => ingr_combine.id, :recipe_id => recipe.id)
    category = Category.create(:name => "Test category")
    ci = CategoriesIngredient.create!(:ingredient_id => ingr_combine.id, :category_id => category.id)
    
    Ingredient.combine_ingredients(ingr_combine, ingr_main)
    ingr_main.reload
    assert_equal "Jalapeno", ingr_main.name
    assert_equal "|jalapeno|jalapenos|jalapeno pepper|jalapeno peppers|", ingr_main.other_names
    assert !Ingredient.find_by_id(ingr_combine.id), "Combined ingredient is gone"
    
    ik.reload
    assert_equal ingr_main.id, ik.ingredient_id, "IngredientsKitchen"

    ir.reload
    assert_equal ingr_main.id, ir.ingredient_id, "IngredientsRecipe"
    
    ci.reload
    assert_equal ingr_main.id, ci.ingredient_id, "CategoriesIngredient"
  end
end
