require 'test_helper'

class ShopControllerTest < ActionController::TestCase

  def setup
    Ingredient.reset_cache
    @user = User.create!(:first => 'Max', :last => 'Dunn', :email => 'max@mail.com', :password => 'password', :password_confirmation => 'password')
    @kitchen = Kitchen.create!(:name => 'Dunn Kitchen', :default_servings => 4)
    @user.kitchen = @kitchen
    @user.save!  
    sign_in(@user)
    @chicken = Ingredient.create!(:name => 'Chicken', :other_names => '|chicken|chickens|')
  end
  
  test "api add new item name" do
    name = "Chicken"
    post :add_item, :item => {:name => name, :needed => true}, :render => 'json'
    assert_response :success
    ik = JSON.parse(response.body).first['ingredients_kitchen']
    assert_equal @kitchen.id, ik['kitchen_id'], 'Kitchen'
    assert_equal @chicken.id, ik['ingredient_id'], 'Ingredient id'
    assert !ik['bought'], 'Bought'
    assert ik['needed'], 'Needed'
    assert !ik['have'], 'Have'
  end
      
  test "api add new unusual item" do
    name = "Baclava d'lite"
    post :add_item, :item => {:name => name, :needed => true}, :render => 'json'
    assert_response :success
    ik = JSON.parse(response.body).first['ingredients_kitchen']
    assert_equal @kitchen.id, ik['kitchen_id'], 'Kitchen'
    assert_equal name, Ingredient.find(ik['ingredient_id']).name, 'Unusual ingredient name'
  end
      
  test "api add item" do
    name = "Chicken"
    note = 'wings only'
    weight = 2
    unit = 'lbs'
    needed = true
    post :add_item, :item => {:name => name, :weight => weight, :unit => unit, :note => note, :needed => needed}, 
      :render => 'json'
    assert_response :success
    ik = JSON.parse(response.body).first['ingredients_kitchen']
    assert_equal @kitchen.id, ik['kitchen_id'], 'Kitchen'
    assert_equal @chicken.id, ik['ingredient_id'], 'Ingredient id'
    assert_equal weight, ik['weight'], 'Weight'
    assert_equal unit, ik['unit'], 'Unit'
    assert_equal note, ik['note'], 'Note' 
    assert_equal needed, ik['needed'], 'Needed' 
    assert_equal false, ik['bought'], 'Bought' 
  end

  test "api update item" do
    ik = IngredientsKitchen.create!({:ingredient_id => @chicken.id, :kitchen_id => @kitchen.id, 
      :weight => '2', :unit => "lbs", :note => 'Organic thighs', :needed => true})

    name = "Chicken"
    note = 'Cheapest wings'
    weight = 1
    unit = 'whole'
    bought = true
    post :update_item, :item => {:id => ik.id, :weight => weight, :unit => unit, :note => note, :bought => bought}, 
        :render => 'json'
    assert_response :success
    ik = JSON.parse(response.body).first['ingredients_kitchen']
    assert_equal @chicken.id, ik['ingredient_id'], 'Ingredient id'
    assert_equal weight, ik['weight'], 'Weight'
    assert_equal unit, ik['unit'], 'Unit'
    assert_equal note, ik['note'], 'Note' 
    assert_equal true, ik['needed'], 'Needed' 
    assert_equal bought, ik['bought'], 'Bought' 
  end

  test "api update item by pantry id" do
    ik = IngredientsKitchen.create!({:ingredient_id => @chicken.id, :kitchen_id => @kitchen.id, 
      :weight => '2', :unit => "lbs", :note => 'Organic thighs', :needed => true})

    note = 'Update by pantry_id'
    post :update_item, :item => {:pantry_id => ik.id, :note => note }, :render => 'json'
    assert_response :success
    ik = JSON.parse(response.body).first['ingredients_kitchen']
    assert_equal @chicken.id, ik['ingredient_id'], 'Ingredient id'
    assert_equal note, ik['note'], 'Note' 
  end

  test "api update item by ingredient id" do
    ik = IngredientsKitchen.create!({:ingredient_id => @chicken.id, :kitchen_id => @kitchen.id, 
      :weight => '2', :unit => "lbs", :note => 'Organic thighs', :needed => true})

    note = 'Update by ingredient_id'
    post :update_item, :item => {:ingredient_id => @chicken.id, :note => note }, :render => 'json'
    assert_response :success
    ik = JSON.parse(response.body).first['ingredients_kitchen']
    assert_equal @chicken.id, ik['ingredient_id'], 'Ingredient id'
    assert_equal note, ik['note'], 'Note' 
  end

  test "api update item by ingredient name" do
    ik = IngredientsKitchen.create!({:ingredient_id => @chicken.id, :kitchen_id => @kitchen.id, 
      :weight => '2', :unit => "lbs", :note => 'Organic thighs', :needed => true})

    note = 'Update by ingredient name'
    post :update_item, :item => {:name => ' Chickens ', :note => note }, :render => 'json'
    assert_response :success
    ik = JSON.parse(response.body).first['ingredients_kitchen']
    assert_equal @chicken.id, ik['ingredient_id'], 'Ingredient id'
    assert_equal note, ik['note'], 'Note' 
  end

  test "api add item render added" do
    name = "chicken"
    post :add_item, :item => {:name => name}, :render => 'added'
    assert_response :success
    resp = JSON.parse(response.body)
    assert_equal 'Chicken', resp['ingredient_name'], 'Name'
    assert_equal @chicken.id, resp['ingredient_id'], 'Ingredient id'
    assert_equal IngredientsKitchen.last.id, resp['item_id'], 'Item id'
  end
      
  test "api update item render none" do
    ik = IngredientsKitchen.create!({:ingredient_id => @chicken.id, :kitchen_id => @kitchen.id, 
      :weight => '2', :unit => "lbs", :note => 'Organic thighs', :needed => true})
    post :update_item, :item => {:id => ik.id, :needed => true}, :render => 'none'
    assert_response :success
    assert_equal '', response.body.strip
  end

  test "api done shopping" do
    ik1 = IngredientsKitchen.create!({:ingredient_id => @chicken.id, :kitchen_id => @kitchen.id, 
      :weight => '2', :unit => "lbs", :note => 'Organic thighs', :needed => true, :bought => true})
    ik2 = IngredientsKitchen.create!({:ingredient_id => @chicken.id, :kitchen_id => @kitchen.id, 
      :weight => '1', :unit => "lbs", :note => 'Breasts', :needed => true, :bought => false})
      
    post :done_shopping, :render => 'json'
    assert_response :success
    
    # Make sure flags set on item bought
    ik1.reload
    assert !ik1.needed, "Needed"
    assert !ik1.bought, "Bought"
    assert ik1.have, "Have"
    
    # Make sure 1 item returned  and flags set correctly
    resp = JSON.parse(response.body)
    assert_equal 1, resp.length
    ik = resp.first["ingredients_kitchen"]
    assert_equal ik2.id, ik["id"]
    assert ik2.needed, "Needed"
    assert !ik2.bought, "Bought"
    assert !ik2.have, "Have"
  end

  test "api clear shopping" do
    ik1 = IngredientsKitchen.create!({:ingredient_id => @chicken.id, :kitchen_id => @kitchen.id, 
      :weight => '2', :unit => "lbs", :note => 'Organic thighs', :needed => true, :bought => true, :have => true})
    ik2 = IngredientsKitchen.create!({:ingredient_id => @chicken.id, :kitchen_id => @kitchen.id, 
      :weight => '1', :unit => "lbs", :note => 'Breasts', :needed => true, :bought => false})
      
    post :clear_shopping_list, :render => 'json'
    assert_response :success
    assert_equal "[]", response.body.strip
    #Make sure clearing ingredients doesn't change have flag
    ik1.reload
    assert ik1.have, "Have"
    ik2.reload
    assert !ik2.have, "Have"
  end
  
  test "add recipe ingredients" do
    Ingredient.create!(:name => 'Rice')
    @recipe = Recipe.create!({:name => 'Rice recipe', :ingredient_list => "1 cup rice", :servings => 1})
    @recipe.process_ingredient_list

    post :add_recipe_ingredients, :recipe_id => @recipe.id, :render => 'json'
    assert_response :success

    resp = JSON.parse(response.body)
    assert_equal 1, resp.length
    ik = resp.first["ingredients_kitchen"]
    assert_equal 'Rice', Ingredient.find(ik['ingredient_id']).name
    assert_equal 4, ik['weight'] # Should be scaled by default_servings = 4
    assert_equal 'cup', ik['unit']
    assert !ik['bought'], 'Bought'
    assert ik['needed'], 'Needed'
    assert !ik['have'], 'Have'
  end

end
