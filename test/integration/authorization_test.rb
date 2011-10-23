require 'test_helper'

class AuthorizationTest < ActionDispatch::IntegrationTest
  fixtures :all
  
  NO_SIGN_IN_PATHS = [
      'GET/', 
      'GET/home',
      'POST/users', 
      'GET/users/sign_in', 'POST/users/sign_in', 
      'GET/users/sign_up', 
      'GET/users/confirmation', 'POST/users/confirmation', 
      'GET/users/confirmation/new',
      'GET/users/unlock', 'POST/users/unlock', 
      'GET/users/unlock/new', 
      'GET/users/password', 'POST/users/password', 'PUT/users/password', 
      'GET/users/password/new', 
      'GET/users/password/edit']
  
  SPECIAL_PATHS = {
    'GET/home/login_guest' => {:sign_in_required => false, :redirect_to => '/', :signed_in_redirect_to => '/' },
    'GET/home/get_started' => {:sign_in_required => false, :redirect_to => '/users/sign_up', :signed_in_redirect_to => '/users/sign_up' },
    'GET/users/sign_out' => {:sign_in_required => true, :redirect_to => '/', :signed_in_redirect_to => '/' },
    'GET/users/cancel' => {:sign_in_required => true, :redirect_to => '/users/sign_up', :signed_in_redirect_to => '/'},
    'DELETE/users' => {:sign_in_required => true, :redirect_to => '/users/sign_in', :signed_in_redirect_to => '/' },
    'DELETE/users/1' => {:sign_in_required => true, :redirect_to => '/users/sign_in', :signed_in_redirect_to => '/users'},
  }    
  
  NO_SIGN_IN_REDIRECT_PATHS = ['GET/home/login_guest', 'GET/home/get_started']
  
  REDIRECT_DIFFERENT_PATHS = ['GET/users/sign_out', 'GET/users/cancel']
  REDIRECTED_TO = [ '/',  '/users/sign_up']
  
  REDIRECT = {'GET/users/sign_out' => '/', 'GET/users/cancel' => '/users/sign_up'}
  
  @@cached_routes = []
  
  # NOTE
  # These tests could be refactored into one test using the SPECIAL_PATHS
  # When creating the routes array hash, merge in the special attributes and then take action accordingly
  
  # -----------
  # The authorization tests need to have a record with id = 1, so set them up here if not one
  # in the fixtures
  def setup
    [Allergy, Appliance, Branch, Category, Course, Ingredient, Kitchen, Meal, MealType, 
      Personality, Product, Recipe, Store].each do |klass|
      if !klass.find_by_id(1)
        obj = klass.new
        obj.id = 1
        obj.save(:validate => false)
      end
    end
  end
  
  #----------
  test "block access redirect to sign_in" do
    # Delete all the paths that don't require a sign-in or redirect to a different page
    routes = get_routes 
    routes.delete_if {|r| NO_SIGN_IN_PATHS.include?(r[:name])}
    routes.delete_if {|r| SPECIAL_PATHS.include?(r[:name])}
    routes.each do |route|
      do_action(route)  
      assert_response :redirect, "For #{route[:name]}"
      assert_equal 'http://www.example.com/users/sign_in', response.redirect_url, "For #{route[:name]}" 
      assert_equal 'You need to sign in or sign up before continuing.', flash[:alert]
    end
  end
  
  #----------
  test "block access with special redirect" do
    routes = get_routes.delete_if {|r| !REDIRECT_DIFFERENT_PATHS.include?(r[:name])}
    routes.each_with_index do |route, index|
      do_action(route)
      assert_redirected_to(REDIRECTED_TO[index], "For #{route[:name]}")
    end
  end
  
  #----------
  test "sign_in not required" do
    routes = get_routes.delete_if {|r| !NO_SIGN_IN_PATHS.include?(r[:name])}
    routes.each do |route|
      do_action(route)
      assert_response :success, "For #{route[:name]}"
    end
  end
  
  #----------
  test "allow access when signed in" do
    do_sign_in
    
    # Get all routes except the ones that need to be handled speciallys
    routes = get_routes.delete_if {|r| SPECIAL_PATHS.include?(r[:name])} 
    routes.each do |route|
      do_action(route)
      assert(flash[:alert] == nil || flash[:alert] == "You are already signed in.", "flash[:alert]=#{flash[:alert]} for #{route[:name]}") 
      assert(response.success? || response.redirect?, "Response was #{response.status}")
    end
  end
  
  #----------
  # NOTE these two 'special paths' methods could be merged into one
  test "special paths signed out" do
    routes = get_routes.delete_if {|r| !SPECIAL_PATHS.include?(r[:name])} 
    routes.each do |route|
      error_msg = "Testing signed out #{route[:name]}"
      sign_out if user_signed_in? #Some calls will sign_ins so make sure we are signed out
      do_action(route)

      if route[:redirect_to].blank?
        assert_response :success, error_msg
      else
        assert_response :redirect, error_msg
        assert_equal "http://www.example.com#{route[:redirect_to]}", response.redirect_url, error_msg
      end
    end
  end
  
  #----------
  test "special paths signed in" do
    routes = get_routes.delete_if {|r| !SPECIAL_PATHS.include?(r[:name])} 
    routes.each do |route|
      error_msg = "Testing signed in #{route[:name]}"
      do_sign_in unless user_signed_in? #Some calls will sign out so make sure we are signed out
      do_action(route)

      if route[:signed_in_redirect_to].blank?
        assert_response :success, error_msg
      else
        assert_response :redirect, error_msg
        assert_equal "http://www.example.com#{route[:signed_in_redirect_to]}", response.redirect_url, error_msg
      end
    end
  end
  
  #=================
  private
  
  #----------
  def get_controller_list
    list = Array.new
    controllers =  Dir.new("#{Rails.root.to_s}/app/controllers").entries
    controllers.each do |controller|
      if controller =~ /_controller/
        list << controller.gsub(".rb","").gsub("_controller","")
      end
    end
    list
  end
  
  #----------
  def get_routes
    # Return cached routes
    return @@cached_routes unless @@cached_routes.empty?
    
    # Get all routes and create array of hashes
    routes = Rails.application.routes.routes.map {|r| {:verb => r.verb, :path_template => r.path, 
       :controller => r.requirements[:controller], :action => r.requirements[:action]}} 
    
    # Delete all the extra paths that AS inserts that aren't used in Rails 3
    extra_paths = %W[new_existing edit_associated add_association destroy_existing add_existing update_column render_field]
    routes.delete_if {|r| extra_paths.find_index {|s| r[:path_template].include?(s)} } 

    # Fixup path to take out variable parts, assign the name and add any special path information
    routes.each do |r| 
      r[:path] = r[:path_template].gsub('(.:format)','').gsub(':id','1')
      r[:name] = r[:verb] + r[:path]
      r.merge!(SPECIAL_PATHS[r[:name]]) unless SPECIAL_PATHS[r[:name]].nil?
    end
    
    # Sort so DELETE are last, otherwise subsequent GETs won't work
    routes = routes.sort { |r1, r2| "#{r1[:verb].gsub('DELETE','Z_DELETE')}#{r1[:path]}" <=> "#{r2[:verb].gsub('DELETE','Z_DELETE')}#{r2[:path]}"}
    
    # Uniq doesn't work on routes, so de-dupe manually. 
    # Unique routes are needed because if there are 2 deletes, the second one will fail
    last_name = ''
    index = 0
    while index < routes.length
      this_name = routes[index][:name]
      if last_name == this_name
        routes.delete_at(index)
      else  
        index = index.next
      end
      last_name = this_name
    end
    
    @@cached_routes = routes
    return @@cached_routes
  end
  
  #----------
  POST_PARAMS = {:id => 1, :user => {:email => 'name@gmail.com'}, :record => {:name => 'Name'}}
  def do_action(route)
    # puts "#{route[:name]}" # For debugging
    putc('.')
    case route[:verb]
      when 'POST'
        begin
          post(route[:path], POST_PARAMS)
        # rescue => exception
        # puts exception.backtrace
        end
      when 'DELETE'
        delete(route[:path])
      when 'PUT'
        put(route[:path], POST_PARAMS)
    else
      get(route[:path])
    end
  end
  
  #----------
  def do_sign_in
    email = 'connie.kwan@realmealz.com'
    password = 'goodfood'
    
    # Some calls delete the user so recreate if necessary
    user = User.find_by_email(email)
    if user.nil?
      user = User.create!(:first => "Connie", :last => "Kwan", :email => email , :password => password, :password_confirmation => password)
      user.confirm!
    end
    post '/users/sign_in', :user => {:email => email , :password => password}
    assert_nil flash[:alert]
    assert_response :redirect
  end
    
end