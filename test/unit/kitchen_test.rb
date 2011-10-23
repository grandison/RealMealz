require 'test_helper'

class KitchenTest < ActiveSupport::TestCase

  test "user emails" do
    k = Kitchen.find_by_id(1)
    assert_equal ["Kwan", "Liu"], k.users.map {|a| a.last}
    assert_equal ["connie@realmealz.com", "ericliu13@gmail.com"], k.users_emails
  end
  
  test "default kitchen" do
    kitchen = Kitchen.create_default_kitchen('Max', 'Dunn')
    assert_equal 'Dunn', kitchen.name
    assert_equal '12345', kitchen.default_meal_days
    
    kitchen = Kitchen.create_default_kitchen('', 'Dunn')
    assert_equal 'Dunn', kitchen.name

    kitchen = Kitchen.create_default_kitchen('Max', '')
    assert_equal 'Max', kitchen.name
    
    kitchen = Kitchen.create_default_kitchen('', '')
    assert_equal 'My', kitchen.name
  end
end
