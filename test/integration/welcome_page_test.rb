require 'test_helper'

class WelcomePageTest < ActionDispatch::IntegrationTest

  def setup
    @user = User.create!(:first => 'Max', :last => 'Dunn', :email => 'max@mail.com', :password => 'password', :password_confirmation => 'password')
    @group = Group.create!(:name => 'Cooking class group', :welcome_page => '/home/welcome_cooking_class')
    @invite_code = InviteCode.create!(:invite_code => 'cookingclass', :group_id => @group.id)
    @user.join_group(@invite_code.invite_code)
  end
  
  test 'group welcome page' do
    sign_in(@user)
    
    exception = assert_raise(ActionView::MissingTemplate) do  
      get @user.group_welcome_page
    end  
    assert_match "Missing template /home/welcome_cooking_class", exception.message
  end

end