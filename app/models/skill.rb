class Skill < ActiveRecord::Base
  
  def self.add_skill_links(steps)
    @skills ||= Skill.all
    @skills.each do |skill|
      next if skill.video_link.blank?
      steps.gsub!("#{skill.name}","<a href='#{skill.youtube_link}' class='video-link', target='_blank' alt='#{skill.name}'>#{skill.name}</a>")
    end
    return steps
  end
  
  def youtube_link
    if video_link.ends_with?('?rel=0')
      return video_link
    else 
      return video_link + '?rel=0'
    end   
  end
  
end


