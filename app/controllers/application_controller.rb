class ApplicationController < ActionController::Base

  helper_method :current_user
  before_filter :require_super_admin
  protect_from_forgery
  before_filter :prepend_view_path_if_mobile
  after_filter :flash_to_headers
  after_filter :check_points
  before_filter :logging

  if ENV['RAILS_MAINTENANCE'] || File.exist?("#{Rails.root}/tmp/maintenance.txt")
    layout 'maintenance'
  end
  #------------------------- 
  # For AJAX calls, return the flash messages in the header
  def flash_to_headers
    return unless request.xhr?
    flash_json = Hash[flash.map{|k,v| [k,ERB::Util.h(v)] }].to_json
    response.headers['X-Flash-Messages'] = flash_json
    flash.discard # don't want the flash to appear when you reload page
  end

  #------------------------- 
  def fix_booleans(hash)
    return nil if hash.nil?
    hash.each do |key, value|
      hash[key] = true if value == 'true' || value == 'TRUE'
      hash[key] = false if value == 'false' || value == 'FALSE'
    end
    return hash
  end
  
  #-------------------------
  def check_user_role(role)
    current_user.nil? || (!role.nil? && current_user.role != role.to_s)
  end
  
  ##############
  protected
  ##############
  
  #------------------------- 
  def skip_check_points
    @skip_check_points_flag = true
  end
  
  ##############
  private
  ##############

  #-------------------------
  def current_user_session
    @current_user_session = @current_user_session || UserSession.find
  end

  #-------------------------
  def current_user
    @current_user = @current_user || (current_user_session && current_user_session.user)
  end
  
  #-------------------------
  def require_user(role = nil)
    if check_user_role(role)
      store_location
      if role.nil?
        flash[:notice] = "You must be logged in to access this page"
      else
        flash[:notice] = "You must be logged in as a #{role.to_s.camelize} to access this page"
      end
      if ['xml', 'json'].include?(params[:render])
        render params[:render].to_sym => {:notice => flash[:notice]}, :status => 401
      else
        redirect_to "/user_session/new"
      end
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
      redirect_to "/users"
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
    @current_user_session = nil
    @current_user = nil
  end
  
  #-------------------------
  def sign_out
    current_user_session.destroy unless current_user_session.nil?
  end
  
  #-------------------------
  def mobile_request?
    request.subdomains.first.downcase == 'm' || params['m'].exists? rescue false
  end
  helper_method :mobile_request?

  #-------------------------
  def prepend_view_path_if_mobile
    if mobile_request?
      prepend_view_path Rails.root + 'app' + 'mobile_views'
    end
  end
  
  #------------------------- 
  def check_points
    return if current_user.nil?

    if @skip_check_points_flag
      @skip_check_points_flag = false
      return
    end
    
    users_point = current_user.check_add_points(self.controller_name, self.action_name)
    unless users_point.nil? || users_point.point.nil?
      flash[:notice] = "You got #{users_point.point.points} point#{users_point.point.points == 1 ? '' : 's'}!" 
      flash[:points] = current_user.get_points
    end
  end
  
  #------------------------- 
  def logging
    if logger && current_user
      logger.info "User: #{current_user.name}"
    end
  end
  
end
