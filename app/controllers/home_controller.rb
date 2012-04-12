class HomeController < ApplicationController

  skip_before_filter :require_super_admin
  
  def index
    @background_recipe = Recipe.random_background_image
  end
  
  def welcome
    @background_recipe = Recipe.random_background_image
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

  def check_invite_code
    invite_code = InviteCode.check_code(params[:user][:invite_code])
    unless invite_code.nil?
      group_teams = Team.where(:group_id => invite_code.group_id)
      if group_teams.empty?
        render :json => {:found => true}
      else
        render :json => {:found => true, :html => render_to_string(:partial => 'select_team', :locals => {:group_teams => group_teams})}
      end
    else
      render :json => {:found => false}
    end
  end
  
  def create_user
    @user = User.create_with_saved(params[:user], session[:temporary_user_id]) 
    if @user.errors.empty?
      sign_in(@user)
      redirect_to '/home/welcome'
    else
      @background_recipe = Recipe.random_background_image
      render :action => :sign_up
    end
  end
  
  def recipes
    # Put the db call in the view so it isn't done when pulling from the cache 
  end
  

  
end
