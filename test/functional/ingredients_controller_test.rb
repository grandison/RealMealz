require 'test_helper'

class IngredientsControllerTest < ActionController::TestCase
  setup do
    # The first user created will be the logged in user
    @user = User.create!(:first => 'Max', :last => 'Dunn', :email => 'max@mail.com', :password => 'password', :password_confirmation => 'password')
    @kitchen = Kitchen.create!(:name => 'Dunn Kitchen')
    @user.kitchen = @kitchen
    @user.role = "kitchen_admin"
    @user.save!  
    
    @ingredient_attributes_1 = {:name => 'Chicken', :other_names => "|chicken|chickens|", :kitchen_id => @kitchen.id}
    @ingredient_attributes_2 = {:name => 'Max bars', :other_names => "|max bars|"}
    @ingredient = Ingredient.create!(@ingredient_attributes_1)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ingredients)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ingredient" do
    assert_difference('Ingredient.count') do
      post :create, :ingredient => @ingredient_attributes_2
    end

    assert_redirected_to ingredients_path
  end

  test "should show ingredient" do
    get :show, :id => @ingredient.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @ingredient.id
    assert_response :success
  end

  test "should update ingredient" do
    put :update, :id => @ingredient.to_param, :ingredient => @ingredient_attributes_1
    assert_redirected_to ingredients_path
  end

  test "should destroy ingredient" do
    # Destroy is turned off for now
    assert_difference('Ingredient.count', 0) do
      delete :destroy, :id => @ingredient.to_param
    end
    assert_response :success
  end
end
