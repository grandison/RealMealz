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
  
  def check_and_add_group_html(line)
    sanitize(line).gsub(/^\*(.*)\*$/,"<br/><span class='recipe-ingredient-group'>\\1</span>").html_safe
  end
  
  #--------Facebook Sharer ref http://www.facebook.com/note.php?note_id=407822831963 ----#
  def facebook_share(url)
    "http://www.facebook.com/sharer.php?u=#{encode_uri_component(url)}"
  end
#-------------------------------------#
  #################
  private
  
  def insert_before_ext(name, insert_text)
    dot_pos = name.rindex('.')
    dot_pos = -1 if dot_pos.nil?
    name.insert(dot_pos, insert_text)
  end
  
  def encode_uri_component(param)
    URI.escape(param, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  end
end


