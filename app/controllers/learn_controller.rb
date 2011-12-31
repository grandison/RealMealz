class LearnController < ApplicationController
  
  skip_before_filter :require_super_admin
  before_filter :require_user
  
  def learn
    s_id = Scategory.find_by_name("technique").id
    @techniques = Skill.find(:all, :conditions => ['video_link is not null and scategory_id = ?', s_id])
    s_id2 = Scategory.find_by_name("ingredient").id
    @ingredients = Skill.find(:all, :conditions => ['video_link is not null and scategory_id =?', s_id2])
    @background_recipe = Recipe.random_background_image
  end  
end
