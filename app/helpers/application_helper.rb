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

  def facebook_share(recipe)
    fb_url = "http://www.facebook.com/dialog/feed"
    recipe_name = url_encode(recipe.name)
    mydescription = "I found this #{recipe_name} recipe on RealMealz.com. It looks delicious and only takes around 30 minutes to make!"
    recipe_url = polymorphic_url([:discover, recipe], :only_path => false)

    return link_to("", "#{fb_url}?app_id=#{FB_APP_ID}&" +
      "link=#{recipe_url}&" +
      "picture=#{recipe.picture.url}&" +
      "name=#{recipe_name}&" +
      "caption=#{recipe_name}%20on%20RealMealz.com&" +
      "description=#{mydescription}&" +
      "redirect_uri=#{recipe_url}",
      :class => 'fb-share')
  end
  
  #################
  private
  
  def insert_before_ext(name, insert_text)
    dot_pos = name.rindex('.')
    dot_pos = -1 if dot_pos.nil?
    name.insert(dot_pos, insert_text)
  end
end
