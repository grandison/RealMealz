class UsersController < ApplicationController
  
  skip_before_filter :require_super_admin, :only => [:new, :create, :show, :my_account, :edit, :update]
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :except => [:new, :create]
  
  #-------------------------
  def new
    @user = User.new
  end

  #-------------------------
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Account registered!"
      redirect_to '/home/welcome'
    else
      render '/users/new'
    end
  end

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
    @user = current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to '/users/my_account'
    else
      render :action => :edit
    end
  end
end
