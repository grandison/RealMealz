require 'test_helper'

class MealsCellTest < Cell::TestCase
  test "display" do
    invoke :display
    assert_select "p"
  end
  

end
