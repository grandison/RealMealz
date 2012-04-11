require 'test_helper'

class DiscoverControllerTest < ActionController::TestCase
  setup do
    Ingredient.reset_cache
    Ingredient.create!(:name => 'Rice', :other_names => "|rice|")
    
    # The first user created will be the logged in user
    @user = User.create!(:first => 'Max', :last => 'Dunn', :email => 'max@mail.com', :password => 'password', :password_confirmation => 'password')
    @kitchen = Kitchen.create!(:name => 'Dunn Kitchen')
    @user.kitchen = @kitchen
    @user.role = "kitchen_admin"
    @user.save!  

    Recipe.delete_all
    @recipe1 = Recipe.create!(:name => 'Cooked rice', :ingredient_list => "1 cup rice", :picture_file_name => 'rice.jpg')
    @recipe2 = Recipe.create!(:name => 'Steamed rice', :ingredient_list => "1 cup rice", :picture_file_name => 'rice.jpg')
    @recipe3 = Recipe.create!(:name => 'Fried rice', :ingredient_list => "1 cup rice", :picture_file_name => 'rice.jpg')
    @recipes_ids = [@recipe1.id, @recipe2.id, @recipe3.id]
  end

  test "discover meal" do
    sign_in(@user)
    
    get :next_recipe
    assert_response :success
    recipe1 = JSON.parse(response.body)
        
    get :next_recipe
    assert_response :success
    recipe2 = JSON.parse(response.body)
        
    get :next_recipe
    assert_response :success
    recipe3 = JSON.parse(response.body)

    assert recipe1['recipe_name'] != recipe2['recipe_name'], 'Recipes should be different'
    assert recipe2['recipe_name'] != recipe3['recipe_name'], 'Recipes should be different'
    assert @recipes_ids.include?(recipe1['recipe_id']), "Recipe 1 in list"
    assert @recipes_ids.include?(recipe2['recipe_id']), "Recipe 2 in list"
    assert @recipes_ids.include?(recipe3['recipe_id']), "Recipe 3 in list"    
  end
  
  test "discover link" do
    sign_in(@user)
    
    get :discover, :id => @recipe1.id
    assert_equal nil, flash[:notice]
    assert_equal nil, flash[:error]
    assert_response :success
    assert_equal @recipe1.name, assigns[:recipes].first.name
    
    # Just to make sure it isn't just showing the first one do the middle
    get :discover, :id => @recipe2.id
    assert_response :success
    assert_equal @recipe2.name, assigns[:recipes].first.name
  end

  test "discover link not found" do
    sign_in(@user)
    
    get :discover, :id => 999999
    assert_equal nil, flash[:notice]
    assert_equal 'Recipe not found', flash[:error]
    assert_response :success
    assert 0 < assigns[:recipes].length, "It should still return some recipes"
  end

end
