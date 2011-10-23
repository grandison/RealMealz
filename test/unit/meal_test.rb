require 'test_helper'

class MealTest < ActiveSupport::TestCase
  
  test "names" do
    setup_recipes_and_courses
    assert_equal "Meal-#{Meal.first.id}", Meal.first.name
    assert_equal 'Saturday', Meal.first.scheduled_date_name
  end

  test 'sorted courses' do
    setup_recipes_and_courses
    courses = Meal.last.courses
    assert_equal 2, courses.length
    assert_equal 0, courses[0].order_num
    assert_equal 'Chicken Curry', courses[0].recipe.name
    assert_equal 1, courses[1].order_num
    assert_equal 'Lasagna', courses[1].recipe.name
  end
  
  test "find course" do
    setup_recipes_and_courses
    c = Course.find_course(TEST_DATE, :dinner, User.first.kitchen_id, order_num = 0)
    assert_equal 0, c.order_num
    assert_equal 'Corn Beef', c.recipe.name
  end

  test "reset course order" do
    setup_recipes_and_courses
    meal = Meal.last
    meal.courses[1].order_num = 99
    meal.reset_course_order

    assert_equal 0, meal.courses[0].order_num
    assert_equal 'Chicken Curry', meal.courses[0].recipe.name
    assert_equal 1, meal.courses[1].order_num
    assert_equal 'Lasagna', meal.courses[1].recipe.name
  end
  
  test "delete course" do
     recipes = setup_recipes_and_courses
     meal = Meal.find_or_create_meal(TEST_DATE + 1, :dinner, User.first.kitchen_id)
     meal.add_course(recipes[3].id)
     course = Course.find_course(TEST_DATE + 1, :dinner, User.first.kitchen_id, order_num = 1)
     Course.delete(course.id)
     
     cs = Course.where(:meal_id => course.meal.id)
     assert_equal 2, cs.length
     assert_equal 0, cs[0].order_num
     assert_equal 'Chicken Curry', cs[0].recipe.name
     assert_equal 2, cs[1].order_num
     assert_equal 'Upside-down Pizza', cs[1].recipe.name
  end
  
  test "setup initial" do
    User.sign_in(User.first)
    recipes = setup_recipes
    setup_active_recipes(recipes)
    
    # Pick a Monday date and use default meal days
    meals = Meal.setup_initial(num_of_meals = 2, Date.new(2011, 1, 3), :dinner, User.current_user.kitchen_id)
    assert_equal 2, meals.length
    assert_equal 1, meals[0].courses.length
    assert_equal 1, meals[1].courses.length
    
    # Set default to Tue, Thur
    User.current_user.kitchen.set_default_meal_days('24')
    Meal.delete_all
    Course.delete_all
    meals = Meal.setup_initial(num_of_meals = 7, Date.new(2011, 1, 3), :dinner, User.current_user.kitchen_id)
    assert_equal 7, meals.length
    assert_equal [0,1,0,1,0,0,0], meals.map {|m| m.courses.length}
    assert_equal '2011-01-03', meals[0].scheduled_date.to_s
    assert_equal '2011-01-04', meals[1].scheduled_date.to_s
  end

end
