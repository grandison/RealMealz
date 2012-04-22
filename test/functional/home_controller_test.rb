require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  def setup
    @user = User.create!(:first => 'Max', :last => 'Dunn', :email => 'max@mail.com', :password => 'password', :password_confirmation => 'password')
    @kitchen = Kitchen.create!(:name => 'Dunn Kitchen', :default_servings => 4)
    @user.kitchen = @kitchen
    @user.save!
    
    @group = Group.create!(:name => 'Cooking class group')
    
    @team_names = ['Chefs', 'Cooking Kooks', 'Slicing Sizzlers']
    @teams = @team_names.map {|name| Team.create!(:name => name, :group_id => @group.id)}
    
    @invite_code = InviteCode.create!(:invite_code => 'cookingclass', :group_id => @group.id)

    @new_user_params = {:user => {:first => 'Betty', :last => 'Baker', :email => 'cook@gmail.com', 
    :password => 'password', :password_confirmation => 'password'}}
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
    
    post :add_team, :team_id => @teams[0].id
    assert_redirected_to "/home/welcome?id=#{@group.id}"
    
    users_team = UsersTeam.find_by_user_id(@user.id)
    assert !users_team.nil?, "UsersTeam should be created"
    assert_equal @teams.first.id, users_team.team_id
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
