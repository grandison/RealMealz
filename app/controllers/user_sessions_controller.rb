class UserSessionsController < ApplicationController
  skip_before_filter :require_super_admin
  before_filter :require_user, :only => :destroy
  
  #-------------------------
  def new
    @user_session = UserSession.new
  end

  #-------------------------
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
        @user_session.user.reset_perishable_token!
        flash[:notice] = "Login successful!"
        if current_user.created_at.to_date == Date.today
          redirect_back_or_default("/home/welcome")
        else
          redirect_back_or_default("/discover")
        end
      else
        render :action => :new
      end
    end
  end
  
  #-------------------------
  def destroy
    current_user_session.destroy
    if ['xml', 'json'].include?(params[:render])
      render :nothing => true
    else
      flash[:notice] = "Logout successful!"
      redirect_back_or_default('/user_session/new')
    end
  end
  
  #-------------------------
  def forgot_password
    @user_session = UserSession.new
  end
  
  #-------------------------
  def forgot_password_email
    user = User.find_by_email(params[:user_session][:email])
    
    if user
      user.deliver_password_reset_instructions!
      flash[:notice] = "Instructions to reset your password have been emailed to you"
      redirect_to root_path
    else
      flash.now[:error] = "Error: No user was found with email address '#{params[:user_session][:email]}'"
      @user_session = UserSession.new(params[:user_session])
      render :action => :forgot_password
    end
  end

end