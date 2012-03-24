class LearnController < ApplicationController
  
  skip_before_filter :require_super_admin
  before_filter :require_user
  
  def learn
    s_id = Scategory.find_by_name("technique").id
    #@techniques = Skill.find(:all, :conditions => ['video_link is not null and scategory_id = ?', s_id])
    @techniques1 = Skill.find(:all, :conditions => ['level = ? and scategory_id = ?', 1, s_id])
    @techniques2 = Skill.find(:all, :conditions => ['level = ? and scategory_id = ?', 2, s_id])
    @techniques3 = Skill.find(:all, :conditions => ['level = ? and scategory_id = ?', 3, s_id])                   
    @techniques4 = Skill.find(:all, :conditions => ['level = ? and scategory_id = ?', 4, s_id])    
    s_id2 = Scategory.find_by_name("ingredient").id
    #@ingredients = Skill.find(:all, :conditions => ['video_link is not null and scategory_id =?', s_id2])
    @ingredients1 = Skill.find(:all, :conditions => ['level = ? and scategory_id = ?', 1, s_id2])
    @ingredients2 = Skill.find(:all, :conditions => ['level = ? and scategory_id = ?', 2, s_id2])
    @ingredients3 = Skill.find(:all, :conditions => ['level = ? and scategory_id = ?', 3, s_id2])                   
    @ingredients4 = Skill.find(:all, :conditions => ['level = ? and scategory_id = ?', 4, s_id2])    

  end  
end
