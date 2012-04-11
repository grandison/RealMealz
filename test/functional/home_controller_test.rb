require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  def setup
    @user = User.create!(:first => 'Max', :last => 'Dunn', :email => 'max@mail.com', :password => 'password', :password_confirmation => 'password')
    @kitchen = Kitchen.create!(:name => 'Dunn Kitchen', :default_servings => 4)
    @user.kitchen = @kitchen
    @user.save!
    
    @group = Group.create!(:name => 'Cooking class group')
    @no_teams_group = Group.create!(:name => 'RealMealz random users')
    
    @team_names = ['Chefs', 'Cooking Kooks', 'Slicing Sizzlers']
    @teams = @team_names.map {|name| Team.create!(:name => name, :group_id => @group.id)}
    
    @invite_code = InviteCode.create!(:invite_code => 'cookingclass', :group_id => @group.id)
    @invite_code_no_group = InviteCode.create!(:invite_code => 'realmealz', :group_id => @no_teams_group.id)  

    @new_user = {:user => {:invite_code => 'cookingclass', :team_id => @teams.first.id, :first => 'Betty', :last => 'Baker', :email => 'cook@gmail.com', :password => 'password', :password_confirmation => 'password'}}
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
    doc = HTML::Document.new(JSON.parse(response.body)['html'])
    assert_select doc.root, 'option' do |options| 
      assert_equal [''] + @team_names, options.map {|o| o.children.first.content}
    end
  end
  
  test 'check invite code no teams' do
    post :check_invite_code, :user => {:invite_code => 'realmealz'}
    assert_equal true, JSON.parse(response.body)['found']
    assert_equal nil, JSON.parse(response.body)['html']
  end
  
  test 'signup bad invite code' do
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
    
    user = User.find_by_email(params[:user][:email])
    assert !user.nil?, "User not created"
    
    users_group = UsersGroup.find_by_user_id(user.id)
    assert !users_group.nil?, "UsersGroup should be created"
    assert_equal @group.id, users_group.group_id
    assert_equal @invite_code.id, users_group.invite_code_id

    users_team = UsersTeam.find_by_user_id(user.id)
    assert !users_team.nil?, "UsersTeam should be created"
    assert_equal @teams.first.id, users_team.team_id
  end
  
  test 'signup no team' do
    UsersTeam.delete_all
    
    params = @new_user
    params[:user][:team_id] = nil
    post :create_user, params
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
