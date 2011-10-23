class DiscoverController < ApplicationController
  
  skip_before_filter :require_super_admin
  before_filter :require_user
  
  #------------------------- 
  def index
    @recipes = Recipe.where("picture_file_name IS NOT NULL").paginate(:page => params[:page], :per_page => 6)      
    @recipes_active = User.current_user.get_active_recipe_ids 
  end
  
  #------------------------- 
  def new_recipes
    @recipes = current_user.get_recipes_list.paginate(:page => params[:page], :per_page => 6) 
    @recipes_active = User.current_user.get_active_recipe_ids 
  end
  
  #------------------------- 
  def add_to_recipe_box
    current_user.add_to_recipe_box(param[:recipe_id])  ## need to write this def
  end
  
  #------------------------- 
  def new_cooking_skills
  end
  
  #------------------------- 
  def update
    if params[:value] == 'true'
      User.current_user.add_recipe(params[:recipe_id], 'discover')
    else
      User.current_user.deactivate_recipe(params[:recipe_id])
    end
    render :nothing => true
  end
  
end