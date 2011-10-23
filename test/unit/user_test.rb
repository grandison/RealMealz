require 'test_helper'

class UserTest < ActiveSupport::TestCase
 
  ########################3
  ## Tests
  ## => add_recipe
  ## => deactivate_recipe
  ## => get_active_recipe_ids 
  
  test "add_recipe" do
    u = User.find_by_id(1)
    u.add_recipe(505,"discover")
    u.add_recipe(507,"discover")
    assert_equal [505,507], u.get_active_recipe_ids

    u.deactivate_recipe(505)
    assert_equal [507], u.get_active_recipe_ids

    u.add_recipe(505,"discover")
    assert_equal [505,507], u.get_active_recipe_ids

    u.update_recipe_rating(505,2)
    assert_equal 2, u.get_recipe_rating(505)
  end
  
  test "get_allergy_free_mains" do
    u = User.find_by_id(2)
    assert_equal [502, 564], u.get_allergy_free_mains
  end
  
  test "add_meal" do
    u = User.find_by_id(1)
    m = u.add_meal(:dinner, Date.today)
    assert_equal 3,m.meal_type_id
    assert_equal 1,m.kitchen_id
    assert_equal Date.today, m.scheduled_date
  end

  test "add_and_destroy_allergy" do
    user = User.find(3)
    assert_equal ["germ", "gluten", "seitan", "wheat"], user.get_allergy_names.sort
    
    user.add_allergy("salmon")  ## adding salmon to allergies
    user = User.find(3)
    assert_equal ["germ", "gluten", "salmon", "seitan", "wheat"], user.get_allergy_names.sort
    
    user.add_allergy("fish")  ## adding fish to allergies, should add fish sub allergies too
    user = User.find(3)
    allergy_names = user.get_allergy_names
    ["fish","trout","sea bas","tuna","grouper","halibut","cod","worcestershire sauce","caviar","roe"].each do |name|
      assert allergy_names.include?(name), "Allergy names did not include '#{name}'"
    end
    
    user.destroy_allergy("fish")
    user = User.find(3)
    assert_equal ["germ", "gluten", "seitan", "wheat"], user.get_allergy_names.sort
  end
  
  test "update_basic_allergy_list" do
    user = User.find(3)
    user.update_basic_allergy_list(['gluten', 'beechnut'])
    
    user = User.find(3)
    assert_equal ['beechnut', 'gluten'], user.get_allergy_names.sort
  end
  
  test "create_with_saved" do
    user = User.create_with_saved(:first => 'Max', :last => 'Dunn', :email => 'max@gmail.com',
      :password => 'hello', :password_confirmation => 'hello',
      :recipes => [502, 564], 'allergies' => ['beechnut', 'gluten'])
    assert_equal "MaxDunn", user.first + user.last
    assert_equal 'kitchen_admin', user.role
    assert_equal "Dunn", user.kitchen.name
    assert_equal ["beechnut", "gluten"], user.get_allergy_names.sort
    assert_equal [502, 564], user.get_active_recipe_ids.sort
  end
end
