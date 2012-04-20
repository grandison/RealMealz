require 'test_helper'

class SettingsControllerTest < ActionController::TestCase
  
  def setup
    @user = User.create!(:first => 'Max', :last => 'Dunn', :email => 'max@mail.com', :password => 'password', :password_confirmation => 'password')
    @kitchen = Kitchen.create!(:name => 'Dunn Kitchen')
    @user.kitchen = @kitchen
    @user.save!  
    sign_in(@user)
  end
  
  #-------------
  test "add remove like item" do
    put :add_like_item, :item => {:name => 'Max Bars'}
    assert_response :success
    ui = UsersIngredient.last
    assert ui.like, "Like item"
    
    put :remove_like_item, :item => {:ingredient_id => ui.ingredient.id.to_s}
    ui = UsersIngredient.last
    assert !ui.like, "Removed like flag"
  end
  
  #-------------
  test "add remove like item api" do
    post :add_like_item, :item => {:name => 'Ice cream'}, :render => 'json'
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 'Ice cream', json[0]['users_ingredient']['ingredient_name']

    post :add_like_item, :item => {:name => 'Honey'}, :render => 'added'
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 'Honey', json['ingredient_name']
    
    get :like_list, :render => 'json'
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 2, json.count
    assert_equal 'Honey', json[0]['users_ingredient']['ingredient_name']
    assert_equal 'Ice cream', json[1]['users_ingredient']['ingredient_name']
    
    post :remove_like_item, :item => {:name=> 'Honey'}
    assert_response :success
    assert_equal '', response.body.strip
  end

  #-------------
  test "add remove avoid item" do
    put :add_avoid_item, :item => {:name => 'wheat'}
    assert_response :success
    ui = UsersIngredient.last
    assert ui.avoid, "Avoid item"
    
    put :remove_avoid_item, :item => {:ingredient_id => ui.ingredient.id.to_s}
    ui = UsersIngredient.last
    assert !ui.avoid, "Removed avoid flag"
  end
  
  #-------------
  test "add remove avoid item api" do
    post :add_avoid_item, :item => {:name => 'wheat'}, :render => 'json'
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 'Wheat', json[0]['users_ingredient']['ingredient_name']

    post :add_avoid_item, :item => {:name => 'peanuts'}, :render => 'added'
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 'Peanuts', json['ingredient_name']
    
    get :avoid_list, :render => 'json'
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 2, json.count
    assert_equal 'Peanuts', json[0]['users_ingredient']['ingredient_name']
    assert_equal 'Wheat', json[1]['users_ingredient']['ingredient_name']
    
    post :remove_avoid_item, :item => {:name=> 'Peanuts'}
    assert_response :success
    assert_equal '', response.body.strip
  end

  #-------------
  # MD Apr-2012. We only test the "have" api call, because there is a similar call in discover/update_pantry for the
  # non-API method
  test "add remove have item api" do
    post :add_have_item, :item => {:name => 'milk'}, :render => 'json'
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 'Milk', json[0]['ingredients_kitchen']['ingredient_name']

    post :add_have_item, :item => {:name => 'eggs'}, :render => 'added'
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 'Eggs', json['ingredient_name']
    
    get :have_list, :render => 'json'
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 2, json.count
    assert_equal 'Eggs', json[0]['ingredients_kitchen']['ingredient_name']
    assert_equal 'Milk', json[1]['ingredients_kitchen']['ingredient_name']
    
    post :remove_have_item, :item => {:name=> 'Eggs'}
    assert_response :success
    assert_equal '', response.body.strip
  end

  #-------------
  test "add exclude item" do
    put :add_exclude_item, :item => {:name => 'wheat'}, :render => 'partial'
    assert_response :success
    assert response.body.starts_with?('<li ingredient-id'), "Response is a li"
    assert response.body.include?('Wheat'), "Response contains ingredient name"

    put :add_exclude_item, :item => {:name => 'wheat'}, :render => 'added'
    assert_response :success
    resp = JSON.parse(response.body)
    assert_equal 'Wheat', resp['ingredient_name']
  end
  
  #-------------
  test "add remove exclude item api" do
    post :add_exclude_item, :item => {:name => 'Salt'}, :render => 'json'
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 'Salt', json[0]['ingredients_kitchen']['ingredient_name']

    post :add_exclude_item, :item => {:name => 'water'}, :render => 'added'
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 'Water', json['ingredient_name']
    
    get :exclude_list, :render => 'json'
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 2, json.count
    assert_equal 'Salt', json[0]['ingredients_kitchen']['ingredient_name']
    assert_equal 'Water', json[1]['ingredients_kitchen']['ingredient_name']
    
    post :remove_like_item, :item => {:name=> 'water'}
    assert_response :success
    assert_equal '', response.body.strip
  end


  
end
