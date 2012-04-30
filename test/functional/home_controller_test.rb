require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  def setup
    @user = User.create!(:first => 'Max', :last => 'Dunn', :email => 'max@mail.com', 
    :password => 'password', :password_confirmation => 'password', :invite_code => '')
    @kitchen = Kitchen.create!(:name => 'Dunn Kitchen', :default_servings => 4)
    @user.kitchen = @kitchen
    @user.save!
    
    @group = Group.create!(:name => 'Cooking class group')
    
    @team_names = ['Chefs', 'Cooking Kooks', 'Slicing Sizzlers']
    @teams = @team_names.map {|name| Team.create!(:name => name, :group_id => @group.id)}
    
    @invite_code = InviteCode.create!(:invite_code => 'cookingclass', :group_id => @group.id)

    @new_user_params = {:user => {:first => 'Betty', :last => 'Baker', :email => 'cook@gmail.com', 
    :password => 'new_password', :password_confirmation => 'new_password', :invite_code => ''}}
  end
  
  test 'signup bad invite code' do
    params = @new_user_params
    params[:user][:invite_code] = 'badcode'
    post :create_user, params
    assert_equal nil, flash[:error]
    assert_equal nil, flash[:notice]
    assert_response :success
    assert_equal "'badcode' is not valid", assigns(:user).errors[:invite_code].first
    assert !User.find_by_email(params[:user][:email])
  end

  test 'good signup' do
    params = @new_user_params
    post :create_user, params
    assert_equal nil, flash[:error]
    assert_equal nil, flash[:notice]
    assert_equal Hash.new, assigns(:user).errors.messages
    assert_redirected_to '/home/welcome'
    
    user = User.find_by_email(params[:user][:email])
    assert user, "should create user"
  end

  test 'signup good invite code' do
    params = @new_user_params
    params[:user][:invite_code] = @invite_code.invite_code
    post :create_user, params
    assert_equal nil, flash[:error]
    assert_equal nil, flash[:notice]
    assert_equal Hash.new, assigns(:user).errors.messages
    assert_redirected_to '/home/select_team'

    user = User.find_by_email(params[:user][:email])
    assert user, "should create user"
    
    users_group = UsersGroup.find_by_user_id(user.id)
    assert !users_group.nil?, "UsersGroup should be created"
    assert_equal @group.id, users_group.group_id
    assert_equal @invite_code.id, users_group.invite_code_id
  end
  
  test 'add team' do
    sign_in(@user)
    @user.join_group(@invite_code.invite_code)
    
    get :select_team
    assert_response :success
    assert_select "#user_team_id option", :count => @teams.count
    
    post :add_team, :user => {:team_id => @teams[0].id}
    assert_redirected_to "/home/welcome?id=#{@group.id}"
    
    users_team = UsersTeam.find_by_user_id(@user.id)
    assert !users_team.nil?, "UsersTeam should be created"
    assert_equal @teams.first.id, users_team.team_id
    assert_equal @group.name, users_team.group.name
    
    # Now change the team and make sure there is only one record
    post :add_team, :user => {:team_id => @teams[1].id}
    assert_equal 1, UsersTeam.count
    users_team = UsersTeam.find_by_user_id(@user.id)
    assert_equal @teams[1].id, users_team.team_id
    assert_equal @group.name, users_team.group.name
  end
  
  test 'signup no team' do
    UsersTeam.delete_all
    
    params = @new_user_params
    params[:user][:team_id] = nil
    post :create_user, params
    assert_equal nil, flash[:error]
    assert_equal nil, flash[:notice]
    assert_redirected_to '/home/welcome'
    
    user = User.find_by_email(params[:user][:email])
    users_team = UsersTeam.find_by_user_id(user.id)
    assert users_team.nil?, "UsersTeam created incorrectly"
  end
  
  test 'edit user' do
    sign_in(@user)
    get :edit_user
    assert_response :success
    assert_select "#user_first[value='#{@user.first}']"
    assert_select "#user_last[value='#{@user.last}']"
    assert_select "#user_email[value='#{@user.email}']"
  end
  
  test 'update user' do
    sign_in(@user)
    post :update_user, @new_user_params
    assert_equal "Account information updated successfully", flash[:notice]
    assert_redirected_to '/home/welcome'
    user_params = @new_user_params[:user]
    assert_equal user_params[:first], current_user.first
    assert_equal user_params[:last], current_user.last
    assert_equal user_params[:email], current_user.email
    
    # Check that password was changed
    sign_out
    user_session = UserSession.create(:email => user_params[:email], :password => user_params[:password])
    assert_equal user_session.user.email, user_params[:email]
  end

  test 'update user no password change' do
    sign_in(@user)
    user_params = @new_user_params[:user]
    user_params.delete(:password)
    user_params.delete(:password_confirmation)
    post :update_user, :user => user_params
    assert_redirected_to '/home/welcome'
    assert_equal user_params[:email], current_user.email
    
    # Check that password was not changed
    sign_out
    user_session = UserSession.create!(:email => user_params[:email], :password => 'password')
    assert_equal user_session.user.email, user_params[:email]
  end
  
  test 'update user with invite code' do
    sign_in(@user)
    user_params = @new_user_params[:user]
    user_params.delete(:password)
    user_params.delete(:password_confirmation)
    user_params[:invite_code] = @invite_code[:invite_code]
    post :update_user, :user => user_params 
    assert_redirected_to '/home/select_team'
    assert_equal @group[:name], current_user.groups.first.name
  end
  
  test 'update user with bad invite code' do
    sign_in(@user)
    user_params = @new_user_params[:user]
    user_params[:invite_code] = 'bad_invite_code'
    post :update_user, :user => user_params
    assert_response :success
    assert_equal ["'bad_invite_code' is not valid"], assigns[:user].errors[:invite_code]
  end
  
  test 'logo redirect index' do
    get :index  
    assert_select "div#realmealz-logo>a[href=/]"
  end
    
  test 'logo redirect old user' do
    sign_in(@user)
    @user.created_at = Date.today - 1.day
    @user.save!
    get :index  
    assert_select "div#realmealz-logo>a[href=/home/welcome]"
  end

  test 'logo redirect new user' do
    @user.created_at = Date.today
    @user.save!
    sign_in(@user)
    get :index  
    assert_select "div#realmealz-logo>a[href=/home/welcome]"
  end  

end
