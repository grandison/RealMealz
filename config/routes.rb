RealMealz::Application.routes.draw do
  
  # Set the root for GET only
  root :to => "home#index", :via => :get
  
  # Match controllers to index for static pages
  # List these out individually so tests can identify them
  
  get "home/about_us"
  
  get '/home' => "home#index"
  get "home/index2"
  get "home/index3"
  get "home/index4"
  get "home/sign_up"
  post "home/sign_up"
  get "home/welcome"
  post "home/welcome"
  get "home/login_guest"
  get "home/get_started"
  get "home/terms_of_service"
	get "home/privacy_policy"
	get "home/about_us"
  get '/admin' => "admin#index"
  
  get '/plan' => "plan#plan"
  post "/plan/update"
  post "/plan/update_meal_order"
  get "/plan/add_course"
  post "/plan/add_recipe_to_meals"
  post "/plan/remove_recipe_from_meals"
  get "/plan/delete_course"
  post "/plan/add_courses_to_shopping_list"

  get '/shop' => "shop#shop_list"
  get "/shop/pantry_list"
  get "/shop/shop_list"
  post "/shop/done_shopping"
  post "/shop/update"
  post "/shop/delete"
  post "/shop/fetch_item"
  post "/shop/update_item"
  post "/shop/update_order"
  post "/shop/add_item"
  post "/shop/remove_item"
  get "/shop/autocomplete_ingredient_name"

  get '/cook' => "cook#cook"

  get '/discover' => "discover#new_recipes"
  get "/discover/new_recipes"
  get "/discover/new_cooking_skills"
  post "/discover/update"

  get '/customize' => "customize#index"
	post '/customize' => "customize#index"
  post "/customize/save"
  get "/customize/autocomplete_ingredient_name"
  get "/customize/kitchen"
	post "/customize/save_kitchen"
	post "/customize/save_food_balance"
	post "/customize/add_like_item"
	post "/customize/remove_like_item"
	
  get "/recipes/process_ingredients"
  post "/recipes/process_ingredients"
  post "/recipes/recipe_setup"
  post "/recipes/move_ingredient"

  post "/sort_order/update_order"

  get "users/my_account"
  
  # authlogic
  resource :account, :controller => "users"
  resources :users
  resource :user_session
  root :controller => "user_sessions", :action => "new"
  
  # Setup ActiveScaffold routes
  resources :recipes do as_routes end
  resources :ingredients do as_routes end
  resources :categories do as_routes end
  resources :users do as_routes end
  resources :kitchens do as_routes end
  resources :appliances do as_routes end
  resources :allergies do as_routes end
  resources :personalities do as_routes end
  resources :sliding_scales do as_routes end
  resources :stores do as_routes end
  resources :branches do as_routes end
  resources :products do as_routes end
  resources :meals do as_routes end
  resources :courses do as_routes end  
  resources :meal_types do as_routes end
  
  # resources :indices
  
  # The priority is based upon order of creation:
  # first created -> highest priority.
  
  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action
  
  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)
  
  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products
  
  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end
  
  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end
  
  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end
  
  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  
  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "home#index"
  
  # See how all your routes lay out with "rake routes"
  
  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
