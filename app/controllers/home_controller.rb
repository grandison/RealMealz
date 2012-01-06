class HomeController < ApplicationController

  skip_before_filter :require_super_admin
  before_filter :require_user, :only => [:welcome]

  def index
    session[:saved] = {:recipes => [], :allergies => []}.with_indifferent_access
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
  
  def sign_up
    save_choices
    @user = User.new
    @user.first = params[:save][:first] rescue ''
    @user.last = params[:save][:last] rescue ''
    sign_out
    @background_recipe = Recipe.random_background_image
  end

  def create_user
    if session[:saved]
      attribs = session[:saved].merge(params[:user]) # Don't save password in session but merge here
    else
      attribs = params[:user]
    end
      
    @user = User.create_with_saved(attribs) 
    if @user.errors.empty?
      sign_in(@user)
      redirect_to '/home/welcome'
    else
      @background_recipe = Recipe.random_background_image
      render :action => :sign_up
    end
  end
  
  ##############
  private
  
  def save_choices
    unless params[:save].nil?
      if params[:save].has_key?(:recipe)
        session[:saved][:recipes] << params[:save][:recipe]
      else
        session[:saved].merge!(params[:save])
      end
    end
  end
end
