require 'test_helper'

class TemporaryUserTest < ActionDispatch::IntegrationTest
  
  def setup
    [Allergy, Appliance, Branch, Category, Ingredient, IngredientsKitchen, IngredientsRecipe, Kitchen, Meal, MealType, 
      Personality, Point, Product, Recipe, SlidingScale, Store, User].each do |klass|
      klass.delete_all
    end
    Ingredient.reset_cache
     
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
  
  test 'should not create user on non protected pages' do
    assert_equal 1, User.count
    get '/'
    assert_equal 1, User.count
    get '/home'
    assert_equal 1, User.count
    get '/home/welcome'
    assert_equal 1, User.count
    get '/home/sign_up'
    assert_equal 1, User.count
    get '/home/about_us'
    assert_equal 1, User.count
    get '/home/privacy_policy'
    assert_equal 1, User.count
    get '/home/terms_of_service'
    assert_equal 1, User.count
    get '/home/faq'
    assert_equal 1, User.count
    get '/home/downloads'
    assert_equal 1, User.count
    get '/home/sponsor'
    assert_equal 1, User.count
    get '/home/ping'
    assert_equal 1, User.count
    get '/home/login'
    assert_equal 1, User.count
    
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