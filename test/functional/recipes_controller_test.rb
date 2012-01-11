require 'test_helper'

class RecipesControllerTest < ActionController::TestCase
  setup do
    Ingredient.reset_cache
    
    # The first user created will be the logged in user
    @user = User.create!(:first => 'Max', :last => 'Dunn', :email => 'max@mail.com', :password => 'password', :password_confirmation => 'password')
    @kitchen = Kitchen.create!(:name => 'Dunn Kitchen')
    @user.kitchen = @kitchen
    @user.role = "kitchen_admin"
    @user.save!  

    @super_user = User.create!(:first => 'Max', :last => 'Superuser', :email => 'super_max@mail.com', :password => 'password', :password_confirmation => 'password')
    @super_user.role = "super_admin"
    @super_user.save!  
    
    Recipe.delete_all
    @super_recipe_attributes = {:name => 'Global recipe', :ingredient_list => "1 cup rice"}
    @super_recipe = Recipe.create!(@super_recipe_attributes)
    @recipe_attributes = {:name => 'Users recipe', :ingredient_list => "1 cup rice", :kitchen_id => @kitchen.id}
    @recipe = Recipe.create!(@recipe_attributes)
  end

  test "should get index" do
    sign_in(@user)
    
    get :index
    assert_response :success
    assert_not_nil assigns(:recipes)
    
    # kitchen-admin should get 1 recipes (plus header)
    assert_select '#recipe-list-table' do
      assert_select 'tr', 2
    end
  end
    
  test "super user should get index" do
    sign_in(@super_user)

    get :index
    assert_response :success

    # super-admin should get 2 recipe (plus header)
    assert_select '#recipe-list-table' do
      assert_select 'tr', 3
    end
  end

  test "should get new" do
    sign_in(@user)
    
    get :new
    assert_response :success
  end

  test "should create recipe" do
    sign_in(@user)

    assert_difference('Recipe.count') do
      post :create, :recipe => @recipe_attributes
    end

    assert_redirected_to '/recipes'
  end

  test "should get edit" do
    sign_in(@user)

    get :edit, :id => @recipe.to_param
    assert_response :success

    # Make sure kitchen_admin can't get supers recipe
    assert_raise ActiveRecord::RecordNotFound do
      get :edit, :id => @super_recipe.to_param
    end
  end

  test "super should get edit" do
    sign_in(@super_user)

    get :edit, :id => @super_recipe.to_param
    assert_response :success
  end

  test "should update recipe" do
    sign_in(@user)

    put :update, :id => @recipe.to_param, :recipe => @recipe_attributes
    assert_redirected_to '/recipes'

    # Make sure kitchen_admin can't update supers recipe
    assert_raise ActiveRecord::RecordNotFound do
      put :update, :id => @super_recipe.to_param, :recipe => @super_recipe_attributes
    end
  end

  test "super should update recipe" do
    sign_in(@super_user)

    put :update, :id => @super_recipe.to_param, :recipe => @super_recipe_attributes
    assert_redirected_to '/recipes'
  end

  test "should destroy recipe" do
    sign_in(@user)

    assert_difference('Recipe.count', -1) do
      delete :destroy, :id => @recipe.to_param
    end
    assert_redirected_to recipes_path

    # Make sure kitchen_admin can't destroy supers recipe
    assert_raise ActiveRecord::RecordNotFound do
      delete :destroy, :id => @super_recipe.to_param
    end
  end

  test "super should destroy recipe" do
    sign_in(@super_user)

    assert_difference('Recipe.count', -1) do
      delete :destroy, :id => @super_recipe.to_param
    end
    assert_redirected_to recipes_path
  end
end
