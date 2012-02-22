require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  def setup
    @user = User.create!(:first => 'Max', :last => 'Dunn', :email => 'max@mail.com', :password => 'password', :password_confirmation => 'password')
    @kitchen = Kitchen.create!(:name => 'Dunn Kitchen', :default_servings => 4)
    @user.kitchen = @kitchen
    @user.save!
    
    @group = Group.create!(:name => 'Cooking class group')
    @invite = InviteCode.create!(:invite_code => 'cookingclass', :group_id => @group.id)  

    @new_user = {:user => {:invite_code => 'cookingclass', :first => 'Betty', :last => 'Baker', :email => 'cook@gmail.com', :password => 'password', :password_confirmation => 'password'}}
  end
  
  test 'bad check invite code' do
    post :check_invite_code, :user => {:invite_code => 'badcode'}
    assert_response :success
    assert_equal false, JSON.parse(response.body)['found']
  end
  
  test 'good check invite code' do
    post :check_invite_code, :user => {:invite_code => 'cookingclass'}
    assert_response :success
    assert_equal true, JSON.parse(response.body)['found']
  end
  
  test 'signup bad group' do
    params = @new_user
    params[:user][:invite_code] = 'badcode'
    post :create_user, params
    assert_response :success
    assert_equal 'invalid', assigns(:user).errors[:invite_code].first
    assert !User.find_by_email(params[:user][:email])
  end

  test 'good signup' do
    params = @new_user
    post :create_user, params
    assert_redirected_to '/home/welcome'
    assert assigns(:user).errors.messages.empty?
    assert User.find_by_email(params[:user][:email]), "User not created"
  end

end
