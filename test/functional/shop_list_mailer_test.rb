require 'test_helper'

class ShopListMailerTest < ActionMailer::TestCase
  def setup
    @kitchen = Kitchen.create!(:name => 'Dunn Family')
    @user = User.create!(:first => 'Max', :last => 'Dunn', :email => 'max@mail.com', :password => 'password', :password_confirmation => 'password')
    @user.kitchen = @kitchen
    @user.save!
    sign_in(@user)

    @tortilla = Ingredient.create!(:name => 'Tortilla', :other_names => '|tortilla|tortillas|')
    @chicken = Ingredient.create!(:name => 'Chicken', :other_names => '|chicken|chicken|')
    @onion = Ingredient.create!(:name => 'Onion', :other_names => '|onion|onions|')

    @ik_tortilla = IngredientsKitchen.create!({:ingredient_id => @tortilla.id, :kitchen_id => @kitchen.id,
      :weight => '4', :unit => "whole", :note => 'Corn', :needed => true, :bought => true})
    @ik_chicken = IngredientsKitchen.create!({:ingredient_id => @chicken.id, :kitchen_id => @kitchen.id,
      :weight => '2', :unit => "lbs", :note => 'Organic thighs', :needed => true})
    @ik_onion = IngredientsKitchen.create!({:ingredient_id => @onion.id, :kitchen_id => @kitchen.id,
      :needed => true, :note => 'Vidalia'})
      
    @item_list = @kitchen.get_sorted_shopping_items
  end

  test "shop list email" do
    email = ShopListMailer.shop_list_email(@user, @item_list).deliver
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [@user.email], email.to
    assert_equal "RealMealz Shopping List", email.subject

    text_body = email.text_part.body.decoded.split("\n")
    assert_equal 'RealMealz Shopping List', text_body[0]
    assert_equal '[ ] Chicken (2 lbs) Organic thighs', text_body[2]
    assert_equal '[ ] Onion, Vidalia', text_body[3]
    assert_equal '[X] Tortilla (4) Corn', text_body[4]
    
    html_body = email.html_part.body.decoded.split("\n").map {|line| line.strip}
    assert_equal '<p><b>RealMealz Shopping List</b></p>', html_body[0]
    assert_equal '[ ] Chicken (2 lbs) Organic thighs<br>', html_body[2]
    assert_equal '[ ] Onion, Vidalia<br>', html_body[3]
    assert_equal '[X] Tortilla (4) Corn<br>', html_body[4]
    
  end
end
