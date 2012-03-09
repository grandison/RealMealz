require 'test_helper'

class AuthorizationTest < ActionDispatch::IntegrationTest
  
  # Defaults:
  # :sign_in_reguired => true
  # :role => kitchen_admin
  SPECIAL_PATHS = [
    {:path => 'GET/', :sign_in_required => false}, 
    {:path => 'GET/home', :sign_in_required => false}, 
    {:path => 'POST/home/create_user', :sign_in_required => false, :redirect_to => '/home/welcome'},
    {:path => 'GET/home/sign_up', :sign_in_required => false},
    {:path => 'POST/home/sign_up', :sign_in_required => false, :sign_out_required => true},
    {:path => 'GET/home/about_us', :sign_in_required => false},
    {:path => 'GET/home/privacy_policy', :sign_in_required => false},
    {:path => 'GET/home/terms_of_service', :sign_in_required => false},
    {:path => 'GET/home/faq', :sign_in_required => false},
    {:path => 'GET/home/downloads', :sign_in_required => false},
    {:path => 'POST/home/check_invite_code', :sign_in_required => false},
    {:path => 'GET/home/ping', :sign_in_required => false},
    {:path => 'GET/home/login', :sign_in_required => false},
    {:path => 'GET/login', :sign_in_required => false},

    {:path => 'POST/users/edit', :redirect_to => '/users/my_account', :flash => 'Account updated!'}, 
    {:path => 'PUT/users/edit', :redirect_to => '/home/welcome', :flash => 'Account updated!'}, 
    {:path => 'GET/users/reset_password', 
      :logged_out_redirect_to => '/user_sessions/forgot_password',
      :logged_in_redirect_to => '/user_sessions/forgot_password'}, 
    {:path => 'POST/users/reset_password', :signs_out => true, 
      :logged_out_redirect_to => '/user_sessions/forgot_password',
      :logged_in_redirect_to => '/user_sessions/forgot_password'}, 

    {:path => 'GET/user_session/new', :sign_in_required => false, :signs_out => true },
    {:path => 'POST/user_session', :sign_in_required => false, :logged_out_flash => 'Login successful!'},
    {:path => 'DELETE/user_session', :role => :kitchen_admin, :signs_out => true, 
      :logged_in_flash => 'Logout successful!',
      :logged_in_redirect_to => '/user_session/new'},
    {:path => 'GET/user_sessions/forgot_password', :sign_in_required => false }, 
    {:path => 'POST/user_sessions/forgot_password', :sign_in_required => false, :redirect_to => '/', :flash => 'Instructions to reset your password have been emailed to you'}, 
      
    
    {:path => 'POST/recipes', :redirect_to => true, :flash => 'Recipe was successfully created.'},  
    {:path => 'PUT/recipes/1', :redirect_to => '/recipes', :flash => 'Recipe was successfully updated.'}, 
    {:path => 'DELETE/recipes/1', :redirect_to => '/recipes'},  
    {:path => 'POST/recipes/create_from_url', :redirect_to => '/recipes', :flash => 'Website not supported'},  

    {:path => 'POST/ingredients/new', :redirect_to => '/ingredients/new_recipe'},  
    {:path => 'POST/ingredients', :logged_in_redirect_to => true, :logged_in_flash => 'Ingredient was successfully created.'},  
    {:path => 'PUT/ingredients/1', :redirect_to => '/ingredients', :flash => 'Ingredient was successfully updated.'},  
    {:path => 'POST/ingredients/combine_ingredients', :logged_in_redirect_to => '/ingredients', :flash => 'Please select both a From and a To ingredient to combine'},  

    {:path => 'POST/cook/done_cooking', :redirect_to => '/cook'},
    {:path => 'POST/discover/cook_now', :redirect_to => '/cook?recipe_id=1'}, 
    {:path => 'POST/settings/save_user', :redirect_to => '/settings'}, 
    {:path => 'POST/track/save_food_balance', :redirect_to => '/track'}, 

    {:path => '/admin_data*', :role => :super_admin, :skip_signed_in_tests => true},
    {:path => 'GET/admin_data*', :role => :super_admin, :skip_signed_in_tests => true},
    {:path => 'PUT/admin_data*', :role => :super_admin, :skip_signed_in_tests => true},
    {:path => 'POST/admin_data*', :role => :super_admin, :skip_signed_in_tests => true},
    {:path => 'DELETE/admin_data*', :role => :super_admin, :skip_signed_in_tests => true},
  ]
  
  @@cached_routes = []
  
  # -----------
  # The authorization tests need to have a record with id = 1, so set them up here if not one
  # in the fixtures
  def setup
    [Allergy, Appliance, Branch, Category, Ingredient, IngredientsKitchen, IngredientsRecipe, Kitchen, Meal, MealType, 
      Personality, Point, Product, Recipe, SlidingScale, Store, User].each do |klass|
      klass.delete_all
      obj = klass.new
      obj.id = 1
      obj.save(:validate => false)
      ActiveRecord::Base.connection.reset_pk_sequence!(klass.table_name)  if ActiveRecord::Base.connection.respond_to?(:reset_pk_sequence!)
    end
    
    @kitchen = Kitchen.find(1)
    @kitchen.update_attributes!(:name => 'Kwan Family')
    @balance = Balance.create!
        
    @email = 'name@gmail.com'
    @super_email = 'super@gmail.com'
    @password = 'password'

    @user = User.find(1)
    @user.update_attributes!(:first => "Connie", :last => "Kwan", 
      :email => @email , :password => @password, :password_confirmation => @password)
    @user.kitchen_id = @kitchen.id
    @user.balance_id = @balance.id
    @user.role = :kitchen_admin
    @user.save!

    @super_user = User.new(:first => "Max", :last => "Dunn", 
      :email => @super_email , :password => @password, :password_confirmation => @password)
    @super_user.role = :super_admin
    @super_user.save!
    
    @recipe = Recipe.find(1)
    @recipe.update_attributes!(:name => 'Tacos', :servings => 4, :picture_file_name => 'taco_picture.jpg', :kitchen_id => @kitchen.id)  

    @ingredient = Ingredient.find(1)
    @ingredient.update_attributes!(:name => 'Tortilla', :other_names => '|tortilla|', :kitchen_id => @kitchen.id )
    
    @ingredients_kitchen = IngredientsKitchen.find(1)
    @ingredients_kitchen.update_attributes!(:weight => 2, :unit => 'cups', :ingredient_id => @ingredient.id, :kitchen_id => @kitchen.id)
    
    @ingredients_recipe = IngredientsRecipe.find(1)
    @ingredients_recipe.update_attributes!(:weight => 1, :unit => 'cups', :ingredient_id => @ingredient.id, :recipe_id => @recipe.id)

    @meal = Meal.find(1)
    @meal.update_attributes!(:kitchen_id => @kitchen.id, :recipe_id => @recipe.id)
    
    Scategory.create!(:name => 'technique')
    Scategory.create!(:name => 'ingredient')
    
    @group = Group.create!(:name => 'Cooking class group')
    @invite = InviteCode.create!(:invite_code => 'cookingclass', :group_id => @group.id)  
  end
  
  #----------
  test "block access" do
    get_routes.each do |route|
      next if route[:sign_in_required] == false
      
      do_action(route)  
      # Bug in assert_response doesn't show message, so show it here first
      if response.status != 302 
        puts "Expected redirect for '#{route[:name]}', Flash[:notice]=#{flash[:notice]}, flash[:error]=#{flash[:error]}"
        assert_response :redirect
      end  
      
      if redirect_to = route[:logged_out_redirect_to]
        assert_equal "http://www.example.com#{redirect_to}", response.redirect_url, "For #{route[:name]}" 
      else
        assert_equal 'http://www.example.com/user_session/new', response.redirect_url, "For #{route[:name]}" 
      end
      if route[:role] == :super_admin
        assert_equal 'You must be logged in as a SuperAdmin to access this page', flash[:notice], "For #{route[:name]}" 
      else
        assert_equal 'You must be logged in to access this page', flash[:notice], "For #{route[:name]}" 
      end
    end
  end
  
  #----------
  test "login not required" do
    get_routes.each do |route|
      next unless route[:sign_in_required] == false
      do_action(route)
      check_response(route[:logged_out_redirect_to] || route[:redirect_to], route[:name])
    end
  end
  
  #----------
  test "allow access when signed in" do
    get_routes.each do |route|
      next if route[:sign_out_required] || route[:skip_signed_in_tests]

      # Have to setup each time because some log out and some delete records that will be needed later
      # Tried using transactions and savepoints, but they don't work on sqlite3
      setup
      do_sign_in(route[:role])
      do_action(route)

      check_response(route[:logged_in_redirect_to] || route[:redirect_to], route[:name])
      flash_msg = route[:logged_in_flash] || route[:flash]
      if flash_msg
        assert(flash[:notice] == flash_msg, "Flash was: flash[:notice]='#{flash[:notice]}', should have been '#{flash_msg}' for #{route[:name]}") 
      else
        assert(flash[:notice] == nil, "No notice expected but flash[:notice]='#{flash[:notice]}' for #{route[:name]}") 
      end
    end
  end
  
  ###########
  private
  ##########
  
  #----------
  def check_response(redirect_to, route_name)
    if redirect_to
      assert_response :redirect
      if redirect_to.is_a?(String)
        assert_equal "http://www.example.com#{redirect_to}", response.redirect_url, "Expected redirect for #{route_name}" 
      end  
      follow_redirect! # follow the redirect to clear any flash messages
    else
      assert(response.success?, "Expected response 200 but was #{response.status} for #{route_name}\n" +
      "flash[:notice]='#{flash[:notice]}'\n" +
      "body=>#{response.body}")
    end
  end
  
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
    # Also delete the admin_data test paths 
    # Also delete the /assets path
    extra_paths = %W[new_existing edit_associated add_association destroy_existing add_existing update_column render_field]
    extra_paths += %W[jstest klass(/:klass) assets]
    routes.delete_if {|r| extra_paths.find_index {|s| r[:path_template].include?(s)} } 

    # Fixup path to take out variable parts, assign the name and add any special path information
    routes.each do |r| 
      r[:path] = r[:path_template].gsub('(.:format)','').gsub(':id','1').gsub('(/:klass)','/recipe').
        gsub(':klasss', 'recipe').gsub(':klass', 'recipe').gsub('*file', 'images/add.png')
      r[:name] = r[:verb] + r[:path]
      special_params = find_special_params(r[:name])
      unless special_params.nil?
        r.merge!(special_params) 
      end
    end
    
    # Sort so DELETE are last
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
  def find_special_params(path)
    SPECIAL_PATHS.each do |sp_original|
      sp = sp_original.dup
      sp_path = sp.delete(:path)
      if path == sp_path # first match whole path
        return sp
      else # see if a wildcard and only match up to that
        trim_pos = sp_path.index('*')
        unless trim_pos.nil?
          trim_path = path[0, trim_pos]
          trim_sp_path = sp_path[0, trim_pos]
          if trim_path == trim_sp_path
            return sp
          end
        end
      end
    end
    return nil
  end
  
  #----------
    
  def do_action(route)
    post_params = {
      :id => 1, 
      :user => {:first => 'Joe', :last => "Smith", :email => 'joe_smith@foomail.com', :invite_code => 'cookingclass',
        :password => 'password', :password_confirmation => 'password'}, 
      :user_session => {:email => 'name@gmail.com'}, 
      :record => {:name => 'Name'},
      :ingredient_id => @ingredient.id,
      :recipe_id => @recipe.id,
      :recipe => {:name => 'Upside down pizza', :ingredient_list => 'tortillas'},
      :ingredient => {:name => 'Carrots', :other_names => "|carrot|carrots"},
      :item => {:name => 'Max Bars'},
      :newveg => 40, :newstarch => 30, :newprotein => 30,
      :item => {:pantry_id => 1, :ingredient_id => @ingredient.id},
      :sort_tag => 'test', :order => '1,2,3',
      :url => 'fake_recipe.html',
      :new_servings => '6',
      :kitchen => {:default_servings => '4'},
      :ingredient_name => 'rice',
    }
      
    # puts route[:name] # For debugging
    putc('.')
    case route[:verb]
      when 'POST'
        begin
          post(route[:path], post_params)
        end
      when 'DELETE'
        delete(route[:path])
      when 'PUT'
        put(route[:path], post_params)
    else
      get(route[:path])
    end
  end
  
  #----------
  def do_sign_in(role = :kitchen_admin)
    if role == :super_admin
      email = @super_email
    else
      email = @email
    end
    post '/user_session', :user_session => {:email => email , :password => @password}
    assert_response :redirect
    assert_equal 'Login successful!', flash[:notice], "For sign_in" 
    get response.redirect_url  # Eat the "login successful" flash notice 
  end
    
end