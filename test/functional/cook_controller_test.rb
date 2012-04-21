require 'test_helper'

class CookControllerTest < ActionController::TestCase
  
  setup do
    MealHistory.delete_all
    @ingredient_tortilla = Ingredient.create!(:name => 'Tortilla', :other_names => '|tortilla|tortillas|')
    @ingredient_chicken = Ingredient.create!(:name => 'Chicken', :other_names => '|chicken|chicken|')
    @ingredient_onion = Ingredient.create!(:name => 'Onion', :other_names => '|onion|onions|')
    
    @category_vegetable = Category.create!(:name => 'vegetable')
    @category_protein = Category.create!(:name => 'protein')
    @category_starch = Category.create!(:name => 'starch')
    
    CategoriesIngredient.create!(:category => @category_starch, :ingredient => @ingredient_tortilla)
    CategoriesIngredient.create!(:category => @category_protein, :ingredient => @ingredient_chicken)
    CategoriesIngredient.create!(:category => @category_vegetable, :ingredient => @ingredient_onion)
    
    @kitchen = Kitchen.create!(:name => 'Dunn Family')
    @recipe = Recipe.create!(:name => 'Tacos', :servings => 4, :picture_file_name => 'taco_picture.jpg', 
      :ingredient_list => "3 cups tortillas\n2 cups chicken, diced\n1 cup onion, sliced")
    @recipe.process_ingredient_list
    @meal = Meal.create!(:kitchen_id => @kitchen.id, :recipe_id => @recipe.id)
    @user = User.create!(:first => "Max", :last => "Dunn", 
      :email => 'max@gmail.com' , :password => 'password', :password_confirmation => 'password')
    @user.kitchen = @kitchen
    @user.save!
    sign_in(@user)
  end

  test 'done cooking' do
    post :done_cooking, :recipe_id => @recipe.id
    assert_redirected_to '/cook'
    kitchen_balance = Balance.get_kitchen_balance(@kitchen)
    assert_equal 1, kitchen_balance[:vegetable], 'Vegetable'
    assert_equal 2, kitchen_balance[:protein], 'Protein'
    assert_equal 3, kitchen_balance[:starch], 'Starch'
  end
  
  test 'done cooking api' do
    post :done_cooking, :recipe_id => @recipe.id, :render => 'nothing'
    assert_response :success
    assert_equal '', response.body.strip
  end

end
