class TrackController < ApplicationController

  skip_before_filter :require_super_admin, :except => :point_tracker
  before_filter :require_user

  #---------------------------------
  def track
    @food_balance = Balance.get_kitchen_balance(current_user.kitchen)
    @target_food_balance = current_user.get_target_food_balance
    @points = current_user.points.group_by(&:description)
    @group = current_user.groups.last if current_user.groups
    @my_team = current_user.teams.find_by_group_id(@group.id) if @group && current_user.teams
    @background_recipe = Recipe.random_background_image
  end
  
  #---------------------------------
  def save_food_balance
    current_user.update_target_food_balance(params[:newveg], params[:newstarch], params[:newprotein])
    redirect_to '/track'
  end

  #---------------------------------
  def point_tracker
    @points_by_group = UsersPoint.points_by_group 
  end
  
  #################
  private
  #################
    
end
