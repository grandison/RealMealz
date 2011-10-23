module ApplicationHelper
  
  def image_mobile_tag(source, options = {})
     if mobile_request? 
       mobile_source = insert_before_ext(source, "-mobile")
       if File.exist?(mobile_source)
         source = mobile_source
       end
     end
     image_tag(source, options)
  end
  
  #################
  private
  
  def insert_before_ext(name, insert_text)
    dot_pos = name.rindex('.')
    dot_pos = -1 if dot_pos.nil?
    name.insert(dot_pos, insert_text)
  end
end
