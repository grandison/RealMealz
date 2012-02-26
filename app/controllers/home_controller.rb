class HomeController < ApplicationController

  skip_before_filter :require_super_admin
  before_filter :require_user, :only => [:welcome]
  
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

  def sign_up
    sign_out
    @user = User.new(params[:user])
    @background_recipe = Recipe.random_background_image
  end

  def check_invite_code
    if InviteCode.check_code(params[:user][:invite_code])
      render :json => {:found => true}
    else
      render :json => {:found => false}
    end
  end
  
  def create_user
    @user = User.create_with_saved(params[:user]) 
    if @user.errors.empty?
      sign_in(@user)
      redirect_to '/home/welcome'
    else
      @background_recipe = Recipe.random_background_image
      render :action => :sign_up
    end
  end
  
end
