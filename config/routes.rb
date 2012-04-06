RealMealz::Application.routes.draw do
  
  # Set the root for GET only
  root :to => "home#index", :via => :get
  
  # Match controllers to index for static pages
  # List these out individually so tests can identify them
  
  ## Social Media shortlinks
  match "/gplus" => redirect("http://gplus.to/RealMealz")
  match "/googleplus" => redirect("http://gplus.to/RealMealz")
  match "/fb" => redirect("http://www.facebook.com/RealMealz")
  match "/facebook" => redirect("http://www.facebook.com/RealMealz")  
  
  ## RealMealz pages
  get '/home' => "home#index"
  get "/home/login" => "home#index" # This link was sent out in a flyer
  get "/login" => "home#index" # This too
  get "/home/sign_up"
  post "/home/sign_up"
  post "/home/create_user"
  get "/home/welcome"
  get "/home/terms_of_service"
	get "/home/privacy_policy"
	get "/home/about_us"
	get "/home/faq"
	get "home/login" => "home#index"
	get "/home/ping"
	get "/home/sponsor" => "home#sponsor"
	
	get "/reports" => 'reports#reports'
	post "/reports/get_group_report" 
	get "/leaderboard" => 'reports#leaderboard'

	get "/home/downloads"
	post "/home/check_invite_code"

  get '/learn' => 'learn#learn'
  
  get '/track' => 'track#track'
	post "/track/save_food_balance"
	get "/track/point_tracker"
  
  get '/shop' => "shop#shop_list"
  get "/shop/pantry_list"
  get "/shop/shop_list"
  post "/shop/update"
  post "/shop/add_item" 
  post "/shop/remove_from_shopping_list"
  post "/shop/update_item"
  post "/shop/email_shopping_list"
  post "/shop/done_shopping"
  post "/shop/add_recipe_ingredients"
  post "/shop/clear_shopping_list"
  get "/shop/clear_shopping_list" => "shop#shop_list"
  get "/shop/autocomplete_ingredient_name"
  post "/shop/update_default_servings"

  get '/cook' => "cook#cook"
  post '/cook/done_cooking'

  get '/discover' => "discover#discover"
  post "/discover/update_pantry"
  post "/discover/next_recipes"
  post "/discover/meal_update"
  post "/discover/recipe_shown"
  post "/discover/cook_now"

  get '/settings' => "settings#settings"
	post '/settings' => "settings#settings"
  post "/settings/save_user"
  get "/settings/autocomplete_ingredient_name"
	post "/settings/add_like_item"
	post "/settings/remove_like_item"
	post "/settings/add_avoid_item"
	post "/settings/remove_avoid_item"
	post "/settings/add_exclude_item"
	post "/settings/remove_exclude_item"
  
  resources :recipes
  post "/recipes/recipe_setup"
  post "/recipes/create_from_url"
  post "/recipes/update_servings"
  post "/recipes/reprocess"
  post "/recipes/new"
  
  resources :ingredients
  post "/ingredients/combine_ingredients"
  post "/ingredients/edit_or_create_by_name"

  # Misc
  post "/sort_order/update_order"
  get "/table_list", :controller => "list", :action => "table_list"
  get "/meals/my_meals"
  
  # authlogic
  get "/user_session/new", :controller=>"user_sessions", :action=>"new"
  post "/user_session", :controller=>"user_sessions", :action=>"create"
  delete "/user_session", :controller=>"user_sessions", :action=>"destroy"
  get "/user_sessions/forgot_password"
  post "/user_sessions/forgot_password", :controller=>"user_sessions", :action=>"forgot_password_email"
  
  get "/users", :controller=>"users", :action=>"my_account"
  get "/users/my_account"
  get "/users/edit"
  put "/users/edit", :controller=>"users", :action=>"update"
  get "/users/reset_password"
  post "/users/reset_password", :controller=>"users", :action=>"reset_password_submit"
  
end
