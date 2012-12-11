require 'test_helper'

class KitchenTest < ActiveSupport::TestCase

  def setup
    @kitchen = Kitchen.create_default_kitchen('', 'Dunn')
    @user = User.create!(:first => 'Max', :last => 'Dunn', :email => 'max@mail.com', :password => 'password', :password_confirmation => 'password', 
      :role => 'kitchen_admin', :kitchen_id => @kitchen.id)
  end

  test "default exclude" do
    ik_exclude_list = @kitchen.get_exclude_list
    assert_equal 'Black pepper', ik_exclude_list[0].ingredient.name
    assert_equal 'Salt', ik_exclude_list[1].ingredient.name
    assert_equal 2, ik_exclude_list.length
  end
  
  test "find or create" do
    ingredient_name = 'Bread'
    note = 'Soft wheat'
    pitem = @kitchen.add_new_pantry_item(ingredient_name, :note => note)
    
    assert_equal @kitchen.id, pitem.kitchen_id, "Kitchen ids don't match"
    assert_equal pitem.note, note, "Pantry notes don't match"
    assert_equal ingredient_name, pitem.ingredient.name, "Ingredient names"
    assert_equal @kitchen.id, pitem.ingredient.kitchen_id, 'Kitchen id of ingredient'
  end  

  test "remove recipe and ingredients" do
    recipe = Recipe.create!(:name => "Max Bars")
    recipe_ingr = Ingredient.create!(:name => "oats")
    other_ingr = Ingredient.create!(:name => "other ingredient")
    ir = IngredientsRecipe.create!(:recipe_id => recipe.id, :ingredient_id => recipe_ingr.id)
    meal = Meal.create(:kitchen_id => @kitchen.id, :recipe_id => recipe.id, :my_meals => true)
    other_kitchen = Kitchen.create!(:name => "Other kitchen")
    
    recipe_ik = IngredientsKitchen.create!(:kitchen_id => @kitchen.id, :ingredient_id => recipe_ingr.id, :have => true)
    other_ingredient_ik = IngredientsKitchen.create!(:kitchen_id => @kitchen.id, :ingredient_id => other_ingr.id, :have => true)
    other_kitchen_ik = IngredientsKitchen.create!(:kitchen_id => other_kitchen.id, :ingredient_id => recipe_ingr.id, :have => true)
    
    @kitchen.remove_recipe_and_ingredients(recipe.id)
    
    meal.reload
    assert !meal.my_meals, "My meals flag reset"
    recipe_ik.reload
    assert !recipe_ik.have, "Have flag reset on matching ingredient"
    other_ingredient_ik.reload
    assert other_ingredient_ik.have, "Have flag not reset on other ingredient"
    other_kitchen_ik.reload
    assert other_kitchen_ik.have, "Have flag not reset on other kitchen's ingredient"
  end

end
