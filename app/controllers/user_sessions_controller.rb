class UserSessionsController < ApplicationController
  skip_before_filter :require_super_admin
  before_filter :require_user, :only => :destroy
  
  def new
    @user_session = UserSession.new
    @background_recipe = Recipe.random_background_image
  end

  def create
    # Check if first time logged in with Authlogic and create new crypted_password.
    user = User.find_by_email(params[:user_session][:email])
    if user and user.password_salt.nil?
      user.update_attributes(:password => params[:user_session][:password], :password_confirmation => params[:user_session][:password])
    end
    
    @user_session = UserSession.new(params[:user_session])
    saved_ok = @user_session.save
    
    if ['xml', 'json'].include?(params[:render])
      render params[:render].to_sym => @user_session, :status => (saved_ok ? 200 : 401)
    else
      if saved_ok
        flash[:notice] = "Login successful!"
        redirect_back_or_default("/home/welcome")
      else
        render :action => :new
      end
    end
  end
  
  def destroy
    current_user_session.destroy
    if ['xml', 'json'].include?(params[:render])
      render :nothing => true
    else
      flash[:notice] = "Logout successful!"
      redirect_back_or_default('/user_session/new')
    end
  end
end