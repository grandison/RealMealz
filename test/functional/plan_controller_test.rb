require 'test_helper'

class PlanControllerTest < ActionController::TestCase
  
 
  test 'initial' do
    sign_in(User.find(:first))
    setup_recipes_and_courses
    get 'index'
    assert_response :success
  end

  test 'add course' do
    sign_in(User.find(:first))
    setup_recipes_and_courses

    get 'add_course', :date => '2011-1-1'
    assert_response :success
    assert_select('ul>li[params]') do |elements|
      test_element_substring('recipe_id=', elements[0])
      test_element_substring('course_id=', elements[0])
    end
  end

  test 'update' do
    sign_in(User.find(:first))
    setup_recipes_and_courses

    get 'update', :course_id => Course.first.id, :recipe_id => 1
    assert_response :success
  end

  #################  
  private
  
  def test_element_substring(substring, element)
    assert(element.to_s.include?(substring), "Substring '#{substring}' not found in: #{element.to_s}")
  end
end
