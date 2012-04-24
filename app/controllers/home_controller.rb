class HomeController < ApplicationController

  skip_before_filter :require_super_admin
  before_filter :require_user, :except => [:index, :welcome, :about_us, :privacy_policy, :terms_of_service, :downloads, 
  :faq, :sponsor, :ping, :sign_up, :create_user, :recipes]
  before_filter :background_recipe, :except => :recipes # MD Apr-2012. For performance, don't include :recipes
  
  def index
  end
  
  # MD Apr-2012. If there is an id parameter and that group has a welcome_page, show that otherwise show the default one
  def welcome
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
  end

  def privacy_policy
  end
  
  def terms_of_service
  end
  
  def downloads
  end

  def faq
  end

  def sponsor
  end

  def ping
    @num_of_users = UsersPoint.where('date_added >= ?', 5.minutes.ago).count
  end

  def sign_up
    sign_out
    @user = User.new
    @user.invite_code = params[:invite_code]
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
      render :action => :sign_up
    end
  end
  
  def recipes
    # Put the db call in the view so it isn't done when pulling from the cache 
  end
  
  #############
  # Below here, users must be logged in
  #############
    
  def edit_user
    @user = current_user
  end

  def update_user
    @user = current_user
    @user.update_and_join_group(params[:user])
    
    if @user.errors.empty?
      sign_in_direct(@user)
      flash[:notice] = 'Account information updated successfully'
      if @user.invite_code.present?
        redirect_to '/home/select_team'
      else
        redirect_to '/home/welcome'
      end
    else
      render :action => :edit_user
    end
  end
  

  # MD Apr-2012. users can belong to more than one group. However, since they just signed up they will only belong
  # to one group at this point
  def select_team
    @group = current_user.groups.first
    @group_teams = Team.where(:group_id => @group.id)
    if @group_teams.blank?
      redirect_to current_user.group_welcome_page
    end
  end
  
  def add_team
    current_user.join_team(params[:team_id])
    redirect_to current_user.group_welcome_page
  end
  
  #########
  # private
  #########
  
  def background_recipe
    @background_recipe = Recipe.random_background_image
  end
  
end
