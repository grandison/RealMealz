class Recipe < ActiveRecord::Base
  has_many :meals
  has_many :meal_histories
  has_many :ingredients_recipes
  has_many :ingredients, :through => :ingredients_recipes
  has_many :recipes_personalities
  has_many :personalities, :through => :recipes_personalities
  has_many :users_recipes
  has_many :users, :through => :users_recipes
  belongs_to :kitchen

  # The lists are to pass information back into the form for easier display, 
  # sort_score is used internally for sorting the recipes by their score
  attr_accessor :prepsteps_list, :cooksteps_list, :ingredient_list, :sort_score

  DEFAULT_URL = "/images/missing:size_id.png"
  DEFAULT_ORIGINAL_LARGE_URL = "/images/missing_large.png"

  # Paperclip resize note:
  #   The > in 1024x1024 is an ImageMagick command that won't resize unless an image dimension is larger
  #   This makes sure that we don't increase the file size of the original file

  STORAGE = 'fog'
  if STORAGE == 's3'
    # s3_aws doesn't recognize the new Amazon S3 path with the bucket at front, like: realmealz.recipes.s3.amazonaws.com    
    has_attached_file :picture, :styles => { :large => "1024x1024>", :medium => "300x300>", :thumbnail => "100x100>" },
    :storage => :s3, 
    :s3_credentials => "#{Rails.root}/config/s3.yml", 
    :s3_options => {:server => 'realmealz-recipes.s3-website-us-west-2.amazonaws.com'},
    :url => ":s3_domain_url",
    :path => ":basename:size_id.:extension",
    :default_url => DEFAULT_URL
  elsif STORAGE == 'fog'
    options = YAML::load(ERB.new(File.read("#{Rails.root}/config/fog_s3.yml")).result)
    has_attached_file :picture, :styles => { :large => "1024x1024>", :medium => "300x300>", :thumbnail => "100x100>" },
    :storage => :fog, 
    :fog_credentials => options['fog_credentials'], 
    :fog_directory => options['bucket'],
    :fog_host => "http://#{options['cloud_front_host_name']}",
    :fog_public => true,
    :url => '/',
    :path => ":basename:size_id.:extension",
    :default_url => DEFAULT_URL
  else
    has_attached_file :picture, :styles => { :large => "1024x1024>", :medium => "300x300>", :thumbnail => "100x100>" },
    :url => "/assets/recipes/:basename:size_id.:extension",  
    :path => ":rails_root/public/assets/recipes/:basename:size_id.:extension",  
    :default_url => DEFAULT_URL
  end

  Paperclip.interpolates :size_id do |attachment, style|
    style == :original ? "" : "_#{style}"
  end

  #------------------------- 
  def ingredient_list
    list = ""
    ingredients_recipes.each do |ir| 
      list << "\n" if ir.group?
      if @new_servings && @new_servings != 0 && servings && servings != 0 && ir.weight && ir.weight != 0
        ir.weight = ir.weight * @new_servings / servings
      end
      list << ir.name_and_description + "\n"
    end
    return list
  end
  
  #------------------------- 
  def new_servings(servings)
    @new_servings = servings
  end
  
  #------------------------- 
  # This prepares the recipe for display by setting up the display fields
  # and adjusting the servings
  def setup_recipe(servings = nil)
    @prepsteps_list = []
    unless prepsteps.nil?
      @prepsteps_list = Skill.add_skill_links(prepsteps).split("\n").map {|line| line.chomp}
    end
    
    @cooksteps_list = []
    unless cooksteps.nil?
      @cooksteps_list = Skill.add_skill_links(cooksteps).split("\n").map {|line| line.chomp}
    end
    
    @new_servings = servings
  end

  #------------------------- 
  # Uploads the recipe picture and process the ingredient_list
  def process_recipe
    unless picture_remote_url.blank? || Rails.env.test?
      self.picture = OpenURI::open_uri(picture_remote_url) 
      extname = File.extname(picture_remote_url)
      basename = File.basename(picture_remote_url, extname)
      self.picture.instance_write('file_name', basename + extname) # Use the original name, not the temp name
    end
    process_ingredient_list
    save!
  end

  #------------------------- 
  # process the ingredients_list into ingredients_recipes
  def process_ingredient_list
    return if @ingredient_list.blank?

    # if this recipe was just created, save original_ingredient_list
    if original_ingredient_list.blank?
      self.original_ingredient_list = @ingredient_list
    end
    
    if @ingredient_list.is_a?(String)
      ingr_array = @ingredient_list.split(/\n/)
    else
      ingr_array = @ingredient_list
    end

    # Usually Rails just sets the key to null. To really delete the record, the following two lines are needed
    ingredients_recipes.each {|ir| ir.delete}
    ingredients_recipes.reload
    
    ingr_array.each_with_index do |line, index|
      line.strip!
      next if line.empty?
      
      # check for groups first, then ingredients. Groups are deliminated with stars like this: *Group*
      attrs = {}
      if line =~ /^\*(.*)\*$/
        attrs[:description] = $1
        attrs[:group] = true
      else
        # If a comma, assume everything past is a comment so only parse the first part but then 
        # add it back in before processing the description
        line.downcase!
        comma_index = line.index(",")
        desc_part = ''
        unless comma_index.blank?
          desc_part = line.slice!(comma_index .. -1)
        end
        attrs[:ingredient] = Ingredient.find_name_and_create(line)
        attrs[:weight] = Ingredient.find_num(line)
        attrs[:unit] = Ingredient.find_unit(line)
        line.slice!(desc_part) # Make sure desc_part is not included twice
        
        # if using the whole_unit, take it out here so it doesn't get repeated in the description
        if attrs[:unit] == 'whole' && !attrs[:ingredient].whole_unit.blank?
          line.slice!(attrs[:ingredient].whole_unit)
        end
        attrs[:description] = Ingredient.find_description(line + desc_part) 
      end
      attrs[:line_num] = index
      attrs[:recipe_id] = self.id
      
      ingredient_recipe = IngredientsRecipe.create!(attrs)
      ingredients_recipes << ingredient_recipe
      Ingredient.standardize_unit(ingredient_recipe)
    end
    @ingredient_list = nil
  end

  #------------------------- 
  def food_balance
    self.updated_at = Time.now if self.updated_at.nil?

    unless self.balance_updated_at == self.updated_at
      protein = Unit.new("0 cup")
      vegetable = Unit.new("0 cup")
      starch = Unit.new("0 cup")
      category = nil

      self.ingredients_recipes.each do |ir|
        unless ir.ingredient.nil?
          category = ir.ingredient.get_balance_category # figure out whether it is protein, veg or fruit
        end
        unless category.nil?
          volume = Unit.new("0 cup")
          ## Set the volume variable
          if !ir.weight.nil? and !ir.unit.nil? # Have weight and unit, add it.
            if ir.ingredient.whole_unit == "head" #for "head" of cauliflower, broccoli, lettuce, add 3 cups
              head_weight = ir.weight*5
              volume = Unit.new("#{head_weight.to_s} cups")
            else
              volume = Unit.new("#{ir.weight.to_s} #{ir.unit}").convert_to_volume
            end
          elsif !ir.weight.nil? and ir.unit.nil? #Have weight but no unit, assume to add weight as cup unit
              volume = Unit.new("#{ir.weight.to_s} cup")
          else  # No weight or unit given.. assume to add one cup
            volume = Unit.new("1 cup")
          end
          ## Add that volume to the right category.
          if category == :protein
            protein += volume
          elsif category == :vegetable or category == :fruit
            vegetable += volume
          elsif category == :starch
            starch += volume
          end
        end
      end
      self.balance_protein = protein.get_scalar
      self.balance_vegetable = vegetable.get_scalar
      self.balance_starch = starch.get_scalar
      self.balance_updated_at = updated_at
      save!
    end
    return  {:protein => balance_protein, :vegetable => balance_vegetable, :starch => balance_starch} 
  end
  
  
  #------------------------- 
  def meal_hash
    ingredients = []    
    ingredients_recipes.each do |ir|
      next if ir.ingredient_id.nil?
      ingredients << {:ingredient_name => ir.ingredient.name,
      :unit => ir.unit, :weight => ir.weight, :description => ir.description,
      :name_and_unit => ir.name}
    end
    
    meal = {:recipe_id => id, 
      :recipe_name => name, 
      :recipe_intro => intro,
      :recipe_prepsteps => prepsteps, 
      :recipe_cooksteps => cooksteps,
      :recipe_source => source, 
      :recipe_source_link => source_link,
      :recipe_servings => servings, 
      :recipe_prep_time => preptime, 
      :recipe_cook_time => cooktime,  
      :picture_thumb => picture(:thumb), 
      :picture_medium =>  picture(:medium),
      :ingredients => ingredients
    }
    return meal
  end

  
  ###################
  # Class methods
  ###################  

  #------------------------- 
  def self.random_background_image
    return nil if Rails.env.test?
    
    background_image_url = nil
    while background_image_url.nil? || background_image_url == DEFAULT_ORIGINAL_LARGE_URL
      rand_id = rand(self.find(:last).id)
      recipe = first(:conditions => [ "id >= ? and public = ?", rand_id, true])
      background_image_url = recipe.picture.url(:large)
    end
    return recipe
  end
  
  #------------------------- 
  def self.create_from_html(url)
    return nil if url.blank?
    
    if url.include?('foodnetwork.com')
      attribs = process_food_network(url)
    elsif url.include?('opensourcefood.com')
      attribs = process_open_source_food(url)
    else
      return nil
    end
    
    recipe = create(attribs)
    recipe.process_recipe
    return recipe
  end
  
 #-------------------------
  def self.process_food_network(url)
    doc = Nokogiri::HTML(open(url))
    attribs = {}
    attribs[:source_link] = url

    attribs[:source] = 'Food Network'
    attribs[:name] = doc.css('#fn-w h1.fn').first.content
    attribs[:preptime] = doc.css('#recipe-meta .prepTime').first.content.to_i rescue 0
    attribs[:cooktime] = doc.css('#recipe-meta .cookTime').first.content.to_i rescue 0
    attribs[:servings] = doc.css('#recipe-meta .yield').first.next_element.content.to_i rescue 4
    attribs[:intro] = doc.css('.body-text .note').first.content rescue ''
    attribs[:picture_remote_url] = doc.css('a#recipe-image').first['href'] rescue nil
    attribs[:ingredient_list] = ''

    group_num = 1
    body_doc = doc.css(".body-text")
    body_doc.css('ul').each do |ul|
      if group_num > 1
        group_node = ul.previous.previous
        if %w(h2 h3).include?(group_node.node_name.downcase)
          group_name = group_node.content
          attribs[:ingredient_list] << "*#{group_name}*\n"
        end
      end
      ul.css('li.ingredient').each do |li|
        attribs[:ingredient_list] << li.content + "\n"
      end
      group_num += 1
    end

    attribs[:cooksteps] = ''
    doc.css('.instructions').each do |inst_divs|
      inst_divs.css('p').each do |p|
        attribs[:cooksteps] << p.content.strip + "\n"
      end
    end
    return attribs
  end

 #-------------------------
  def self.process_open_source_food(url)
    doc = Nokogiri::HTML(open(url))
    doc = doc.css('#recipe_container')

    attribs = {}
    attribs[:source_link] = url
    attribs[:source] = 'Open Source Food'
    attribs[:name] = doc.css('h1.subheading').first.content
    attribs[:picture_remote_url] = "http://www.opensourcefood.com" + doc.css('#recipe_pic_new img').first['src'] rescue nil
    attribs[:ingredient_list] = ''

    body_doc = doc.css("#recipe_ingredients")
    body_doc.css('#tag_container_new').remove
    body_doc.css('#tastebud_promo').remove
    
    body_doc.css('ul').each do |ul|
      ul.css('li').each do |li|
        attribs[:ingredient_list] << li.content.strip.delete("\n\r").squeeze(' ') + "\n"
      end
    end

    attribs[:cooksteps] = ''
    doc.css('#method_inner li').each do |li|
      attribs[:cooksteps] << li.content.strip.delete("\n\r").squeeze(' ') + "\n"
    end
    return attribs
  end
  
end        

