ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "authlogic/test_case" 

# Unit tests
class ActiveSupport::TestCase

  # Authlogic setup
  setup :activate_authlogic
  
  # Normally sign_in is accessed from a controller. For testing models, setup the necessary Authlogic 
  # controller to create a UserSession
  def sign_in(user)
    UserSession.create(user)
  end

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

end

# Functional tests, also runs everything above
class ActionController::TestCase
end

# Integration tests
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

  #def current_user
  #  if !defined?(session) || session.nil? || session["warden.user.user.key"].nil?
  # else
  #    User.find(session["warden.user.user.key"][1][0])
  #  end
  #end

  def sign_in(user)
    session["warden.user.user.key"] = new.Array[4]
    session["warden.user.user.key"][1] = new.Array
    session["warden.user.user.key"][1][0] = user.id
  end

  def sign_out
    get '/users/sign_out'
  end

end