require 'test_helper'

class PickCellTest < Cell::TestCase
  test "pick_list" do
    invoke :pick_list
    assert_select "p"
  end
  

end
