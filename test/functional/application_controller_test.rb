require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  
  test 'fix booleans' do
    hash = {'a' => 'foo', 'b' => 'false', :c => 'true', 'd' => 'TRUE'}
    @controller.fix_booleans(hash)
    assert_equal 'foo', hash['a']
    assert_equal false, hash['b']
    assert_equal true, hash[:c]
    assert_equal true, hash['d']
  end

end
