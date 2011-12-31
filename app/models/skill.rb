class Skill < ActiveRecord::Base
  
  def self.add_skill_links(steps)
    @skills ||= Skill.all
    @skills.each do |skill|
      next if skill.video_link.blank?
      steps.gsub!("#{skill.name}","<a href='#{skill.video_link}' class='video-link', target='_blank' alt='#{skill.name}'>#{skill.name}</a>")
    end
    return steps
  end
end


