class AuthenticationsController < ApplicationController

  skip_before_filter :require_super_admin
  before_filter :require_user

  # POST /authentications
  # POST /authentications.json
  def create
    omniauth = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    message = "I found this #{session[:recipe].name} recipe on RealMealz.com. It looks delicious and only takes around 30 minutes to make!"
    if authentication
      fb_post_and_redirect(message, omniauth)
    elsif current_user
      current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
      fb_post_and_redirect(message, omniauth)
    end
  end

  protected

  # This is necessary since Rails 3.0.4
  # See https://github.com/intridea/omniauth/issues/185
  # and http://www.arailsdemo.com/posts/44
  def handle_unverified_request
    true
  end

  def fb_post_and_redirect(message, omniauth)
    graph = Koala::Facebook::GraphAPI.new(omniauth.credentials.token)
    fb_data = {:name => session[:recipe].name, :picture => session[:recipe].picture.url}
    fb_data.merge!(:link => session[:recipe].source_link) unless session[:recipe].source_link.blank?
    graph.put_wall_post(message, fb_data)
    redirect_to discover_path
  end

end
