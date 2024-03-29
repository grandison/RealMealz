class UsersController < ApplicationController
  
  skip_before_filter :require_super_admin, :only => [:show, :my_account, :edit, :update, :reset_password, :reset_password_submit]
  before_filter :require_user, :except => [:reset_password, :reset_password_submit]

  #-------------------------
  def show
    @user = current_user
  end

  #-------------------------
  def my_account
    @user = current_user
  end

  #-------------------------
  def edit
    @user = current_user
  end

  #-------------------------
  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      UserSession.create(@user) if Rails.env.test? # If doing test, we turn off automatic login so do it here
      flash[:notice] = "Account updated!"
      redirect_to current_user.group_welcome_page
    else
      render :action => :edit
    end
  end
  
  #-------------------------
  def reset_password
    get_user_by_token
  end

  #-------------------------
  def reset_password_submit
    get_user_by_token
    return if @user.nil?
    
    if @user.update_attributes(params[:user].merge({:active => true}))
      @user.reset_perishable_token!
      flash[:notice] = "Successfully reset password."
      redirect_to @user.group_welcome_page
    else
      flash[:error] = "There was a problem resetting your password."
      render :action => :reset_password
    end
  end  
  
  ############
  private
  ###########
  def get_user_by_token
    @token = params[:token]
    @user = User.find_using_perishable_token(@token, 1.week)
    if @user.nil?
      flash[:error] = "Password reset token not valid"
      redirect_to :controller => :user_sessions, :action => :forgot_password
    end
  end

end
