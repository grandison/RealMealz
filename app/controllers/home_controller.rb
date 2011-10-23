class HomeController < ApplicationController

  skip_before_filter :require_super_admin

  def index
    session[:saved] = {:recipes => [], :allergies => []}.with_indifferent_access
  end

  def index1
    save_choices
  end

  def index2
    save_choices  
  end

  def index3
    save_choices
  end

  def index4
    save_choices  
    @allergies_checked = session[:saved][:allergies]
    @allergy_names = Allergy.get_displayed_allergy_names
  end
  
  def sign_up
    save_choices
    @user = User.new
    @user.first = params[:save][:first] rescue ''
    @user.last = params[:save][:last] rescue ''
    sign_out
  end

  def welcome
    @user = User.create_with_saved(session[:saved].merge(params[:user])) # Don't save password in session but merge here
    if @user.errors.empty?
      sign_in(@user)
    else
      render :action => :sign_up
    end
  end

  def login_guest
    sign_in User.find_by_role('guest')
    redirect_to :action => 'index'
  end

  def get_started
    sign_out
    redirect_to '/users/sign_up'
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
