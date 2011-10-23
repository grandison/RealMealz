ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  TEST_DATE = Date.new(2011, 1, 1)
  
  # Unit tests (models) need to tie into ActiveScaffold current_user 
  ActiveRecord::Base.current_user_proc = proc {User.current_user}

  # Normally sign_in is accessed from a controller. For testing models, setup the necessary Authlogic 
  # controller to create a UserSession
  def sign_in_hide(user)
    if Authlogic::Session::Base.controller.nil?
      Authlogic::Session::Base.controller = Authlogic::ControllerAdapters::RailsAdapter.new(ApplicationController.new)
    end
    if Authlogic::Session::Base.controller.request.nil?
      Authlogic::Session::Base.controller.request = ActionController::Request.new({'rack.input' => ''}) 
    end
    UserSession.create(user)
  end
  
  # ApplicationController defines current_user for all controllers and ActiveScaffold injects a 
  # current_user method into every model. 
  # For the test methods, call the ApplicationController current_user
  def current_user_hide
    Authlogic::Session::Base.controller.current_user
  end

  # for unit tests (models) need to tie into ActiveScaffold current_user 
  #ActiveRecord::Base.current_user_proc = proc {current_user}    
  
  def setup_recipes
    Recipe.delete_all
    recipes = []
    ['Corn Beef', 'Chicken Curry', 'Lasagna', 'Upside-down Pizza'].each do |name|
      recipe = Recipe.new(:name => name)
      recipe.save!(:validate => false)
      recipes << recipe
    end
    return recipes
  end

  def setup_active_recipes(recipes)
    UsersRecipe.delete_all
    recipes.each do |recipe|
      UsersRecipe.create!(:user_id => User.first, :recipe_id => recipe.id, :active => true)
    end
  end

  def setup_courses(recipes)
    Meal.delete_all
    Course.delete_all
    meal = Meal.find_or_create_meal(TEST_DATE, :dinner, User.first.kitchen_id)
    meal.add_course(recipes[0].id)
    meal = Meal.find_or_create_meal(TEST_DATE + 1.day, :dinner, User.first.kitchen_id)
    meal.add_course(recipes[1].id)
    meal.add_course(recipes[2].id) 
  end

  def setup_recipes_and_courses
    recipes = setup_recipes
    setup_active_recipes(recipes)
    setup_courses(recipes)
    return recipes
  end
end


class ActionController::TestCase
end

# These tests only work for integration tests
class ActionDispatch::IntegrationTest

  # Add other integration helper methods here
  def check_get_success(path)
    get(path)
    assert_response :success, "For path #{path}"
  end

  def get_methods(controller)
    eval("#{controller}.new.methods") - ApplicationController.methods - Object.methods - ApplicationController.new.methods
  end

  def user_signed_in?
    defined?(@integration_session) && @integration_session.session["warden.user.user.key"]
  end

  def current_user
    if !defined?(session) || session.nil? || session["warden.user.user.key"].nil?
      User.find(:first)
    else
      User.find(session["warden.user.user.key"][1][0])
    end
  end

  def sign_in(user)
    session["warden.user.user.key"] = new.Array[4]
    session["warden.user.user.key"][1] = new.Array
    session["warden.user.user.key"][1][0] = user.id
  end

  def sign_out
    get '/users/sign_out'
  end

end