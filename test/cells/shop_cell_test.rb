require 'test_helper'

class ShopCellTest < Cell::TestCase
  test "shop" do
    invoke :shop
    assert_select "p"
  end
  

end
