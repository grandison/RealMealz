class UserSessionsController < ApplicationController
  skip_before_filter :require_super_admin
  before_filter :require_user, :only => :destroy
  
  def new
    @user_session = UserSession.new
  end
  
  def create
    # Check if first time logged in with Authlogic and create new crypted_password.
    user = User.find_by_email(params[:user_session][:email])
    if user and user.password_salt.nil?
      user.update_attributes(:password => params[:user_session][:password], :password_confirmation => params[:user_session][:password])
    end
    
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Login successful!"
      redirect_back_or_default(plan_url)
    else
      render :action => :new
    end
  end
  
  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_back_or_default(new_user_session_path)
  end
end