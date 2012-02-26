require 'test_helper'

class PointsTest < ActionDispatch::IntegrationTest
  
  POINT_LIST = <<-EOF
    home:create_user, Signup, 15, 1 
    track:save_food_balance, Target VPG, 10, 1
    settings:add_exclude_item, Add item to Exclude list, 3, 30
    recipes:index, Going into Manage Recipes List, 5, 1
    recipes:create, Adding recipe, 10, 100
    ingredients:index, Going into Managing ingredients list, 5, 1
    discover:update_pantry, Add item to I have list, 5, 30
    settings:add_avoid_item, Add item to I avoid list, 5, 30
    discover:meal_update, Add to my meals, 5, 100
    discover:meal_update, starring recipe, 5, 100
    discover:recipe_shown, Scrolling through a recipe, 1, 1000
    discover:next_recipes, Doing an 'i want' search, 5, 100
    discover:next_recipes, Doing a 'star only' search, 5, 100
    shop:add_recipe_ingredients, Adding recipe items to shopping list, 2, 1000
    shop:add_item, Adding solo item to shopping list, 2, 1000
    shop:update_item, Editing an item, 5, 1000
    shop:update, Checking off an item, 1, 1000
    shop:done_shopping, Done Shopping, 10, 100
    recipes:update_servings, Cook - Changing the serving size, 5, 1000
    cook:done_cooking, Cook - Click on 'I Cooked This!', 10, 1000
  EOF
  
  def setup
    [Allergy, Appliance, Branch, Category, Ingredient, IngredientsKitchen, IngredientsRecipe, Kitchen, Meal, MealType, 
      Personality, Point, Product, Recipe, SlidingScale, Store, User].each do |klass|
      klass.delete_all
    end
    Ingredient.reset_cache
    
    params = {}
    POINT_LIST.each_line do |line|
      params[:name], params[:description], params[:points], params[:max_times] = line.split(',').map {|p| p.strip}
      Point.create!(params)
    end
    
    @ingredient = Ingredient.create!(:name => 'Tortilla', :other_names => '|tortilla|tortillas|')
    @kitchen = Kitchen.create!(:name => 'Dunn Family')
    @ingredients_kitchen = IngredientsKitchen.create!(:weight => 2, :unit => 'each', :ingredient_id => @ingredient.id, :kitchen_id => @kitchen.id)
    @recipe = Recipe.create!(:name => 'Tacos', :servings => 4, :picture_file_name => 'taco_picture.jpg', :kitchen_id => @kitchen.id)
    @meal = Meal.create!(:kitchen_id => @kitchen.id, :recipe_id => @recipe.id)
    @user = User.create!(:first => "Max", :last => "Dunn", 
      :email => 'max@gmail.com' , :password => 'password', :password_confirmation => 'password')
    @user.kitchen = @kitchen
    @user.save!
  end
  
  test 'points table setup' do
    sum = Point.all.inject(0) {|sum, p| sum + p.points }
    assert_equal 114, sum
  end
  
  test 'max points' do
    do_sign_in
    (1..4).each do
      get '/recipes'
    end  
    assert_equal 5, @user.get_points
  end
  
  test 'signup' do
    group = Group.create!(:name => 'Cooking class group')
    InviteCode.create!(:invite_code => 'cookingclass', :group_id => group.id)  
    post '/home/create_user', :user => {:invite_code => 'cookingclass', :first => 'Betty', :last => 'Baker', :email => 'cook@gmail.com', :password => 'password', :password_confirmation => 'password'}
    assert_redirected_to '/home/welcome'
    user = User.find_by_email('cook@gmail.com')
    assert_equal 15, user.get_points   
  end
  
  test 'track:food balance' do
    do_sign_in
    get '/track' # call this to setup a default balance
    assert_response :success
    post '/track/save_food_balance', :newveg => 40, :newstarch => 30, :newprotein => 30
    assert_equal 10, @user.get_points
  end
  
  test 'exclude' do
    do_sign_in
    post '/settings/add_exclude_item', :item => {:name => 'tortilla'}
    assert_equal 3, @user.get_points
  end
  
  test 'recipes' do
    do_sign_in
    get '/recipes'
    assert_equal 5, @user.get_points
  end
  
  test 'recipes:create' do
    do_sign_in
    post '/recipes', :recipe => {:name => 'tacos', :ingredient_list => '1 tortilla'}
    assert_equal 10, @user.get_points
  end
  
  test 'ingredients' do
    do_sign_in
    get '/ingredients'
    assert_equal 5, @user.get_points
  end

  test 'discover:update_pantry' do
    do_sign_in
    post '/discover/update_pantry', :ingredient_id => @ingredient.id, :checked => true
    assert_equal 5, @user.get_points
  end
  
  test 'settings:add_avoid_item' do
    do_sign_in
    post '/settings/add_avoid_item', :item => {:ingredient_id => @ingredient.id}
    assert_equal 5, @user.get_points
  end

  test 'discover:meal_update' do
    do_sign_in
    post '/discover/meal_update'
    assert_equal 5, @user.get_points
  end

  test ' discover:recipe_shown' do
    do_sign_in
    post '/discover/recipe_shown', :recipe_id => @recipe.id
    assert_equal 1, @user.get_points
  end

  test 'discover:next_recipes' do
    do_sign_in
    post '/discover/next_recipes'
    assert_equal 5, @user.get_points
  end

  test 'shop:add_recipe_ingredients' do
    do_sign_in
    post '/shop/add_recipe_ingredients', :recipe_id => @recipe.id
    assert_equal 2, @user.get_points
  end

  test 'shop:add_item' do
    do_sign_in
    post '/shop/add_item', :item => {:name => 'Lime'}
    assert_equal 2, @user.get_points
  end

  test 'shop:update_item' do
    do_sign_in
    post '/shop/update_item', :item => {:ingredient_id => @ingredient.id, :note => 'Corn'}
    assert_equal 5, @user.get_points
  end

  test 'shop:update' do
    do_sign_in
    post '/shop/update', :id => @ingredients_kitchen.id, :value => false, :shop => false
    assert_equal 1, @user.get_points
  end

  test 'shop:done_shopping' do
    do_sign_in
    post '/shop/done_shopping'
    assert_equal 10, @user.get_points
  end

  test 'recipes:update_servings' do
    do_sign_in
    post '/recipes/update_servings', :recipe_id => @recipe.id, :new_servings => 2
    assert_equal 5, @user.get_points
  end

  test 'cook:done_cooking' do
    do_sign_in
    post '/cook/done_cooking', :recipe_id => @recipe.id
    assert_equal 10, @user.get_points
  end

  #############
  private
  #############
  
  def do_sign_in
    post '/user_session', :user_session => {:email => @user.email , :password => @user.password}
    assert_response :redirect
    assert_equal 'Login successful!', flash[:notice], "For sign_in" 
    get response.redirect_url  # Eat the "login successful" flash notice 
  end
    

  
end