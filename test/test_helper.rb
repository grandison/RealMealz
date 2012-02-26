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
    @current_user_session = nil
    @current_user = nil
  end
  
  def signed_in?
    UserSession.find
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

end