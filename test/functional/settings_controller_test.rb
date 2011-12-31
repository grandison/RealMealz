require 'test_helper'

class SettingsControllerTest < ActionController::TestCase
  
  def setup
    @user = User.create!(:first => 'Max', :last => 'Dunn', :email => 'max@mail.com', :password => 'password', :password_confirmation => 'password')
    @kitchen = Kitchen.create!(:name => 'Dunn Kitchen')
    @user.kitchen = @kitchen
    @user.save!  
    sign_in(@user)
  end
  
  test "add remove like item" do
    put :add_like_item, :item => {:name => 'Max Bars'}
    assert_response :success
    ui = UsersIngredient.last
    assert ui.like, "Like item"
    
    put :remove_like_item, :item => {:ingredient_id => ui.ingredient.id.to_s}
    ui = UsersIngredient.last
    assert !ui.like, "Removed like flag"
  end

  test "add remove avoid item" do
    put :add_avoid_item, :item => {:name => 'wheat'}
    assert_response :success
    ui = UsersIngredient.last
    assert ui.avoid, "Avoid item"
    
    put :remove_avoid_item, :item => {:ingredient_id => ui.ingredient.id.to_s}
    ui = UsersIngredient.last
    assert !ui.avoid, "Removed avoid flag"
  end

  test "add exclude item" do
    put :add_exclude_item, :item => {:name => 'wheat'}
    assert_response :success
    assert response.body.starts_with?('<li ingredient-id'), "Response is a li"
    assert response.body.include?('Wheat'), "Response contains ingredient name"

    put :add_exclude_item, :item => {:name => 'wheat'}, :render => 'added'
    assert_response :success
    resp = JSON.parse(response.body)
    assert_equal 'Wheat', resp['ingredient_name']
  end

  
end
