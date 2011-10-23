class Recipe < ActiveRecord::Base
  has_many :courses
  has_many :meals, :through => :courses
  has_many :ingredients_recipes
  has_many :ingredients, :through => :ingredients_recipes
  has_many :recipes_personalities
  has_many :personalities, :through => :recipes_personalities
  has_many :users_recipes
  has_many :users, :through => :users_recipes
  default_scope :include => :ingredients
  
  attr_accessor :ingredients_on_hand, :ingredients_needed, :ingredient_list, :instruction_list
  
  has_attached_file :picture, :styles => { :medium => "300x300>", :thumbnail => "100x100>" },
   :url => "/assets/recipes/:basename:size_id.:extension",  
   :path => ":rails_root/public/assets/recipes/:basename:size_id.:extension",  
   :default_url => "/assets/recipes/missing:size_id.png"
  
  Paperclip.interpolates :size_id do |attachment, style|
    style == :original ? "" : "_#{style}"
  end
  
  #------------------------- 
  def food_balance
    Balance.get_food_balance(self.ingredients_recipes)
  end 
  
  #------------------------- 
  def setup_recipe
    @ingredients_on_hand = []
    @ingredients_needed = []
    self.ingredients.each do |ingredient|
      if current_user.kitchen.need_pantry_ingredient?(ingredient)
        @ingredients_needed << ingredient
      else
        @ingredients_on_hand << ingredient
      end
    end
    
    @ingredient_list = []
    @instruction_list = []

    lines = self.original.split("\n").map {|line| line.chomp}
    return if lines.empty?
    
    processing_ingredients = true
    lines.each do |line|
      next if line.blank?
      
      if line.include?("**")
        if processing_ingredients
          processing_ingredients = false
          next
        else
          break
        end
      end
      
      if processing_ingredients
        @ingredient_list << line
      else
        @instruction_list << line
      end
    end
  end
  

  ###################
  # Class methods
  ###################  
  
  #------------------------- 
  ## Parses the fed ingredient array and returns an array 
  ## Usage: new_array = parse_ingredients(unparsed_text_in_array)
  ## Return Array is in format of [["name of ingr", Ingr_id, Unit, Group],["", "", 1 g, spices], ["cucumber", 1175, 4, nil], ["white wine vinegar", 1386, 0.333333 cup], ["lemon juice", 1226, 1 tbs], ["virgin olive oil", 1361, 2 tsp], ["sugar", 1475, 1.5 tsp], ["salt", 1389, 1 tsp], ["pepper", 1390, 0.125 tsp], ["", "", 0.5 cup], ["shallot", 1101, 1], ["fresh parsley", 1448, 0.5 cup], ["fresh oregano", 1446, 1 tsp], ["almond", 1262, 3 tbs]]
  def self.parse_ingredients(ingredient_array)
  
  	## fetch list of ingredients from db
  	ingr_array = Ingredient.sort_by_length
  	
    @return_array = Array.new   ## store sets of [name, ing_key, qty]
    @qty=nil  #Unit variable that holds both the scalar and the unit of the ingredient
    @ingredient_id=nil #ingredient position in the db if a match is found
   	@unit=nil 
   	@ingr_index=nil
   	@found_ingr=nil
   	@group=nil  #The group that the ingredient belongs to (ie ((Marinade)))
    
    ## Iterate through each line in ingredient_array
    (0..ingredient_array.length-1).each do |cnt1|
    	## if the line is empty, go to next line
    	
   		if ingredient_array[cnt1].strip.empty?
   			cnt1=cnt1+1
   	  elsif (ingredient_array[cnt1].include? "((")
   	    array = ingredient_array[cnt1].scan(/\(\((\w+)\)\)/)
   	    @group = array[0].to_s
   	    cnt1=cnt1+1
   		else
  			## Finds @ingredient_id
      	## Singularizes all words in ingredient_array and tries to match to ingredients db
  			line = ingredient_array[cnt1].make_singular.remove_brackets
  			## check line for ingredients from the ingredient db
  			@ingr_index = ingr_array.index {|ingr| line.include?(ingr)} rescue nil 
  			if !@ingr_index.nil?
  				@found_ingr = ingr_array[@ingr_index]
  				@ingredient_id = Ingredient.find_by_name(@found_ingr).id
  			else
  				##Ingredient Not Found 
  				Rails.logger.info "WARNING: Ingredient not found in: #{line} :You need to add it to the Ingredient table."
  			end
  	
  			## finds @qty
  			#line = line.remove_brackets
  			@unit = line.find_unit
  			 
        ## Exception Handling for different ways of representing units (cups, teaspoons, etc.)
  			if !@unit.nil?
  				if @unit == "c."  
  					@unit="cup"
  				elsif @unit == "t."
  					@unit="teaspoon"
  				elsif @unit == "T."
  					@unit="tablespoon"
  				elsif @unit == "oz."
  					@unit="oz"
  				elsif @unit == "OZ."
  					@unit="oz"
  				elsif @unit == "pinch"  ## handles pinch and translates it to 1/4 teaspoon
  					@number = "1/4 "
  					@unit = "teaspoon"
  				end		
  				## there is a unit, find closest num to the unit
  				@number=line.find_closest_num(@unit)
  				@qty = Unit.new("#{@number.to_s} #{@unit}")
  			else
  				if !@found_ingr.nil? ##ingredient found
  					@number = line.find_closest_num(@found_ingr) ## try using ingredient as "unit" to find number
  					if !@number.nil? ##number found
  						@qty = Unit.new("#{@number} whole")
  					else ##number not found with ingredient as key, just search for any number
  						@number = line.find_num
  						if !@number.nil?
  							@qty = Unit.new("#{@number}")					 		
  						end
  					end
  				end			
  			end
  				
  			## build output array
  			if !@found_ingr.nil? and !@qty.nil? 
  				@return_array << [@found_ingr, @ingredient_id, @qty, @group]
  			elsif @found_ingr.nil? and !@qty.nil?
  				@return_array << ["","", @qty, @group]
  			elsif !@found_ingr.nil? and @qty.nil?
  				@return_array << [@found_ingr, @ingredient_id, nil, @group]
  			elsif @found_ingr.nil? and @qty.nil?
  				@return_array << ["","",nil, @group]
  			end
  
  			## reset variables
  			@unit=nil
  			@qty=nil
  			@number=nil
  			@ingr_index=nil
  			@ingredient_id=nil
  			@found_ingr=nil
  					
  			Rails.logger.info "DEBUG: return array from parse_ingredients #{@return_array.inspect}"
  		end
  	end
    return @return_array
  end
      
  
  #------------------------- 
  ## Adds the recipe into the DB
  ## Usage: 
  ## add_recipe("random recipe  all ingredients,  all instructions  \n\n\n\  hey he \n", "random recipe",[["salt",981,"4 tsp"],["ground black pepper",1049,"2 tsp"],["habanero chili",1071,"3"],["serrano chili",1072,"3"],["",793,"1 cup"],["vegetable oil",934,""],["pineapple",804,"3.5 lbs"],["cider",976,"0.25 cup"]], "chop it, cook it", 3, 5,10, "RealMealz", "tags", "no")    
  ##
  def self.add_recipe(original, name, intro, ingr_array, prepsteps, cooksteps, servings, preptime, cooktime, source, tags, skills, picture, approved)
    @r = Recipe.new 
    @r.original = original
    @r.name = name
    @r.intro = intro
    @r.prepsteps = prepsteps
    @r.cooksteps = cooksteps
    @r.servings = servings
    @r.preptime = preptime    
    @r.cooktime = cooktime
    @r.source = source
    @r.tags = tags
    @r.skills = skills
    @r.approved = approved
    @r.picture_file_name = picture
    
    (0..ingr_array.length-1).each do |cnt|
    
      ## import ingr id:  ingr_array[cnt][1] 
      @i_id = ingr_array[cnt][1]
      @ir = IngredientsRecipe.new 
      
      ## link ingredient_id and recipe_id together
      if !@i_id.nil?
        @ir.ingredient_id = @i_id
      end
      @ir.recipe_id = @r.id
      if !ingr_array[cnt][2].nil?  #!= ""
        @my_unit = ingr_array[cnt][2] #weight and unit
        
        Rails.logger.info "CLASS: #{@my_unit.class}"
        if !@my_unit.get_scalar.nil?
          Rails.logger.info "GET_SCALAR: #{@my_unit.get_scalar}"
          @ir.weight = @my_unit.get_scalar
        end
        if !@my_unit.unit.nil?
          Rails.logger.info "GET_UNIT: #{@my_unit.get_unit}"
          @ir.unit = @my_unit.get_unit
        end
      else
        Rails.logger.info "WARNING: Ingredient #{@id} has no associated WEIGHT or UNITS!"
      end
      if !ingr_array[cnt][3].nil?
        @ir.group = ingr_array[cnt][3]
      end
      @ir.save
      @r.ingredients_recipes << @ir
    end 
    @r.save!
    return @r.id
  end
  
  #------------------------- 
  def self.get_all_recipe_ids
    Recipe.find(:all) { |x| x.id}
  end
  
  #------------------------- 
  def self.find_similar(match_recipes)
    #Get ingredients from current recipe, since we can assume they have the ingredients to make these recipes
    match_ingredients = []    
    match_recipes.each do |r|
      match_ingredients << r.ingredients
    end
    
    #Add in ingredients from pantry
    match_ingredients << current_user.kitchen.ingredients_kitchens.map {|ik| ik.ingredient}
    
    match_ingredients = match_ingredients.flatten.uniq
    
    similar_recipes = []
    all.each do |recipe|
      if recipe.ingredients.all? {|i| match_ingredients.include?(i)}
        unless match_recipes.include?(recipe)
          similar_recipes << recipe
          break if similar_recipes.size >= 5
        end
      end
    end
puts similar_recipes.map{|i| i.name}.sort.to_json    
    return similar_recipes
  end
  
end        

