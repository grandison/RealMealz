class ApplicationController < ActionController::Base

  helper_method :current_user
  before_filter :require_super_admin
  protect_from_forgery
  before_filter :prepend_view_path_if_mobile

  #------------------------- 
  ActiveScaffold.set_defaults do |config|
    config.theme = :blue
  end

  ##############
  private
  ##############

  #-------------------------
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  #-------------------------
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end
  
  #-------------------------
  def require_user(role = nil)
    if current_user.nil? || (!role.nil? && current_user.role != role.to_s)
      store_location
      if role.nil?
        flash[:notice] = "You must be logged in to access this page"
      else
        flash[:notice] = "You must be logged in as a #{role.to_s.camelize} to access this page"
      end
      redirect_to new_user_session_url
      return false
    end
  end

  #-------------------------
  def require_super_admin
    require_user(:super_admin)
  end

  #-------------------------
  def require_no_user
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page"
      redirect_to(account_url)
      return false
    end
  end
  
  #-------------------------
  def store_location
    session[:return_to] = request.fullpath
  end
  
  #-------------------------
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  
  #-------------------------
  def sign_in(user)
    UserSession.create!(:email => user.email, :password => user.password)
  end
  
  #-------------------------
  def sign_out
    current_user_session.destroy unless current_user_session.nil?
  end
  
  #-------------------------
  def mobile_request?
    request.subdomains.first.downcase == 'm' rescue false
  end
  helper_method :mobile_request?

  #-------------------------
  def prepend_view_path_if_mobile
    if mobile_request?
      prepend_view_path Rails.root + 'app' + 'mobile_views'
    end
  end
 
end
