require 'test_helper'

class CourseTest < ActiveSupport::TestCase
    
  test "create course" do
    recipes = setup_recipes
    Course.create_course(recipes[0].id)
    cs = Course.find(:all)
    assert_equal 1, cs.length
    assert_equal 'Corn Beef', cs[0].recipe.name
  end
  
  test "update course" do
    recipes = setup_recipes
    c = Course.create_course(recipes[0].id)
    Course.update_course(c.id, recipes[1].id)
    cs = Course.find(:all)
    assert_equal 1, cs.length
    assert_equal 'Chicken Curry', cs[0].recipe.name
  end
  
  test "add second course" do
    recipes = setup_recipes
    Course.create_course(recipes[0].id)
    Course.create_course(recipes[1].id)
    cs = Course.find(:all)
    assert_equal 2, cs.length
    assert_equal 0, cs[0].order_num
    assert_equal 'Corn Beef', cs[0].recipe.name
    assert_equal 1, cs[1].order_num
    assert_equal 'Chicken Curry', cs[1].recipe.name
  end  
end
