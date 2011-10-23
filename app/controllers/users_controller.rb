class UsersController < ApplicationController
  
  skip_before_filter :require_super_admin
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :except => [:new, :create]
  
  active_scaffold :users do |config|
    config.list.columns = [:first, :last, :email, :city, :state, :role, :kitchen, 
      :allergies, :personalities, :sliding_scales, :categories]
    config.columns = [:first, :last, :email, :street, :city, :state, :zip, :role, :kitchen, 
      :users_allergies, :users_personalities, :users_sliding_scales, :users_categories, :users_recipes]
    config.columns[:users_allergies].label = "Allergies"
    config.columns[:users_personalities].label = "Personalities"
    config.columns[:users_sliding_scales].label = "Sliding Scales"
    config.columns[:users_categories].label = "Categories"
    config.columns[:users_recipes].label = "Selected Recipes"
    config.columns[:role].form_ui = :select
    config.columns[:role].options = {:options => User::ROLES}
  end
  
  #-------------------------
  def new
    @user = User.new
  end

  #-------------------------
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Account registered!"
      redirect_to '/plan'
    else
      render :action => :new
    end
  end

  #-------------------------
  def show
    @user = current_user
  end

  #-------------------------
  def edit
    @user = current_user
  end

  #-------------------------
  def update
    @user = current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to account_url
    else
      render :action => :edit
    end
  end
end
