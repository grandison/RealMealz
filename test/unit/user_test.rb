require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @kitchen = Kitchen.create!(:name => 'Dunn Family')
    @user = User.create(:first => 'Max', :last => 'Dunn', :email => 'max@mail.com', :password => 'password', :password_confirmation => 'password')
    @user.kitchen_id = @kitchen.id
    @user.role = 'kitchen_admin'
    @user.save!
    
    @group1 = Group.create!(:name => "Barbara's Cooking Class")
    @group2 = Group.create!(:name => "Cisco Employee Challenge")
    @team10 = Team.create(:name => 'Cooking Clowns', :group_id => @group1.id)
    @team11 = Team.create(:name => 'Sauteeing Supremes', :group_id => @group1.id)
    @team20 = Team.create(:name => 'Router Raiders', :group_id => @group2.id)
  end

  test "get favorite recipes" do
    Recipe.delete_all
    Meal.delete_all
    r1 = Recipe.create!(:name => 'Public Recipe 1', :picture_file_name => 'recipe1.jpg')
    r2 = Recipe.create!(:name => 'Public Recipe 2', :picture_file_name => 'recipe2.jpg', :public => true)
    r3 = Recipe.create!(:name => 'Private Recipe 3', :picture_file_name => 'recipe3.jpg', :public => false, :kitchen_id => @kitchen.id)
    r4 = Recipe.create!(:name => 'Private other Recipe 4', :picture_file_name => 'recipe4.jpg', :public => false, :kitchen_id => 123456)
    r5 = Recipe.create!(:name => 'Private without picture Recipe 5', :public => false, :kitchen_id => @kitchen.id)
    r6 = Recipe.create!(:name => 'Private/Public Recipe 6', :picture_file_name => 'recipe5.jpg', :public => true, :kitchen_id => @kitchen.id)
    m1 = Meal.create!(:kitchen_id => @kitchen.id, :recipe_id => r2.id, :starred => true)
    
    # Get all recipes for this user
    # Should include all public recipes, plus all private recipes for this kitchen, even if no picture
    r_list_ids = @user.get_favorite_recipes(ids_shown = [], {'star' => false})
    [r1, r2, r3, r5, r6].each do |r|
      assert r_list_ids.include?(r.id), r.name + ' not found'
    end

    # Get starred recipes
    r_list_ids = @user.get_favorite_recipes(ids_shown = [], {'star' => true})
    assert_equal r2.id, r_list_ids.first, 'Starred recipe is first'
    assert_equal 1, r_list_ids.count, 'Number of recipes returned'

    # Not one starred recipes, should get normal list
    m1.update_attributes!(:starred => false)
    r_list_ids = @user.get_favorite_recipes(ids_shown = [], {'star' => true})
    assert_equal 6, r_list_ids.count, 'None starred: number of recipes'

    # Get search list
    r_list_ids = @user.get_favorite_recipes(ids_shown = [], {'search' => 'Recipe 2'})
    assert_equal 6, r_list_ids.count, 'Searched for Recipe 2'
    assert_equal r2.id, r_list_ids.first
    
    # Seen should be last
    m2 = Meal.create!(:kitchen_id => @kitchen.id, :recipe_id => r1.id, :seen_count => 1)
    r_list_ids = @user.get_favorite_recipes(ids_shown = [], {'star' => false})
    assert_equal r1.id, r_list_ids.last, "Seen should be last"
    
  end

  test "avoid categories" do
    Recipe.delete_all
    Ingredient.delete_all
    Ingredient.reset_cache
    
    ingr_bread = Ingredient.create!(:name => 'Bread', :other_names => '|bread|')
    ingr_beef = Ingredient.create!(:name => 'Beef', :other_names => '|beef|')
    ingr_chicken = Ingredient.create!(:name => 'Chicken', :other_names => '|chicken|')
    ingr_meat = Ingredient.create!(:name => 'Meat', :other_names => '|meat|')
    
    category = Category.create!(:name => 'meat')
    category.categories_ingredients << CategoriesIngredient.create!(:ingredient_id => ingr_beef.id)
    category.categories_ingredients << CategoriesIngredient.create!(:ingredient_id => ingr_chicken.id)
    
    recipe_toast = Recipe.create!(:name => 'Toast', :picture_file_name => '1.jpg', :ingredient_list => '1 slice bread')
    recipe_toast.process_ingredient_list
    recipe_beef = Recipe.create!(:name => 'Big old BBQ', :picture_file_name => '1.jpg', :ingredient_list => '1 lb beef')
    recipe_beef.process_ingredient_list
    recipe_chicken = Recipe.create!(:name => 'Stirfry', :picture_file_name => '1.jpg', :ingredient_list => '1 lb chicken')
    recipe_chicken.process_ingredient_list
    
    assert_equal 3, Recipe.count
    assert_equal "Beef", recipe_beef.ingredients[0].name
    
    @user.get_favorite_recipes(ids_shown = [], {})
    assert_equal 3, @user.recipe_list.length
    @user.recipe_list.each do |rl|
      assert_equal 0, rl[:sort_score]
    end
      
    # Should delete recipe "beef"  
    @user.update_users_ingredients(ingr_beef.name, :avoid => true)
    @user.get_favorite_recipes(ids_shown = [], {})
    assert_equal 2, @user.recipe_list.size
    assert_equal 0, @user.recipe_list[0][:sort_score]
    assert_equal 0, @user.recipe_list[1][:sort_score]

    # Avoid meat should delete chicken and beef
    @user.update_users_ingredients(ingr_beef.name, :avoid => false)
    @user.update_users_ingredients(ingr_meat.name, :avoid => true)
    @user.get_favorite_recipes(ids_shown = [], {})
    assert_equal 1, @user.recipe_list.size
    assert_equal 0, @user.recipe_list[0][:sort_score]
  end

  test "update like avoid" do
    name = 'Soy sauce'
    
    # Create new user_ingredient
    user_ingr1 = @user.update_users_ingredients(name, :like => true)
    assert_equal name, user_ingr1.ingredient.name, "Ingredient name"
    assert user_ingr1, "Ingredient user, :like"
    assert_equal @kitchen.id, user_ingr1.ingredient.kitchen_id, "Kitchen id of ingredient"
    
    # Make sure second time finds it by name and doesn't create a new one
    user_ingr2 = @user.update_users_ingredients(name, :like => false, :avoid => true)
    assert_equal user_ingr1.id, user_ingr2.id, 'Created separate ingredient'
    assert user_ingr2.avoid, "Avoid not set"
    
    # Now find by id
    user_ingr2 = @user.update_users_ingredients(user_ingr2.ingredient.id, :avoid => false)
    assert !user_ingr2.avoid, "Avoid not set"
  end

  test "add_and_destroy_allergy" do
    gluten = Allergy.create(:name => 'gluten')
    Allergy.create(:name => 'wheat', :parent_id => gluten.id)
    Allergy.create(:name => 'beechnut')

    @user.add_allergy('beechnut') 
    assert_equal ['beechnut'], @user.get_allergy_names.sort

    @user.add_allergy('gluten')  
    assert_equal ['beechnut', 'gluten', 'wheat'], @user.get_allergy_names.sort

    @user.destroy_allergy("gluten")
    @user.reload
    assert_equal ["beechnut"], @user.get_allergy_names.sort
  end  

  test "update_basic_allergy_list" do
    gluten = Allergy.create(:name => 'gluten')
    Allergy.create(:name => 'wheat', :parent_id => gluten.id)
    Allergy.create(:name => 'beechnut')

    @user.update_basic_allergy_list(['gluten', 'beechnut'])
    assert_equal ['beechnut', 'gluten', 'wheat'], @user.get_allergy_names.sort
  end
  
  test "join team" do
    sign_in(@user)
    @user.join_team(@team10.id)
    assert_equal @team10.name, @user.teams.first.name

    # If joining another team in the same group, should just update the team    
    @user.join_team(@team11.id)
    assert_equal @team11.name, @user.teams.first.name
    assert_equal 1, @user.teams.count

    # If joining a team in another group, should add a new record    
    @user.join_team(@team20.id)
    assert_equal @team20.name, @user.teams[1].name
    assert_equal 2, @user.teams.count
  end

end
