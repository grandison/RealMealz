class HomeController < ApplicationController

  skip_before_filter :require_super_admin
  
  def index
    @background_recipe = Recipe.random_background_image
  end
  
  # MD Apr-2012. If there is an id parameter and that group has a welcome_page, show that otherwise show the default one
  def welcome
    @background_recipe = Recipe.random_background_image
    welcome_page = nil
    if params['id'] 
      group = Group.find(params['id'])
      if group
        welcome_page = group.welcome_page
      end  
    end  
    unless welcome_page.blank?
      render welcome_page
    end  
  end

  def about_us
    @background_recipe = Recipe.random_background_image
  end

  def privacy_policy
    @background_recipe = Recipe.random_background_image
  end
  
  def terms_of_service
    @background_recipe = Recipe.random_background_image
  end
  
  def downloads
    @background_recipe = Recipe.random_background_image
  end

  def ping
    @num_of_users = UsersPoint.where('date_added >= ?', 5.minutes.ago).count
  end

  def sign_up
    sign_out
    @user = User.new(params[:user])
    @background_recipe = Recipe.random_background_image
  end

  def create_user
    @user = User.create_with_saved(params[:user], session[:temporary_user_id]) 
    if @user.errors.empty?
      sign_in(@user)
      if @user.invite_code.present?
        redirect_to '/home/select_team'
      else
        redirect_to '/home/welcome'
      end
    else
      @background_recipe = Recipe.random_background_image
      render :action => :sign_up
    end
  end
  
  # MD Apr-2012. users can belong to more than one group. However, since they just signed up they will only belong
  # to one group at this point
  def select_team
    group = current_user.groups.first
    @group_teams = Team.where(:group_id => group.id)
    if @group_teams.blank?
      redirect_to current_user.group_welcome_page
    else
      @background_recipe = Recipe.random_background_image
    end
  end
  
  def add_team
    current_user.join_team(params[:team_id])
    redirect_to current_user.group_welcome_page
  end
  
  def recipes
    # Put the db call in the view so it isn't done when pulling from the cache 
  end
  
end
