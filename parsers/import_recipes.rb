#require "C:/connie/Workspace/RealMealz/config/environment"
#require "C:/connie/Workspace/RealMealz/app/models/recipe.rb"
#require File.expand_path('../../config/environment', __FILE__)
require 'ruby_ext'

#Rails.logger.auto_flushing = true

#############################################################################  
## Call this file in "rails console" to batch add recipes to the DB. 
## Modify the path at end of file to import the right directory of recipes
###  Usage:  
## Step 1: load 'parsers/import_recipes.rb' #adds picture name
## Step 2: move .jpg/.png files over to /public/assets/recipes
## Step 3 run 'rake paperclip:refresh CLASS=Recipe'


###################
# Class methods
###################  

#------------------------- 
## Parses the fed ingredient array and returns an array 
## Usage: new_array = parse_ingredients(unparsed_text_in_array)
## Return Array is in format of [["name of ingr", Ingr_id, Unit, Group],["", "", 1 g, spices], ["cucumber", 1175, 4, nil], ["white wine vinegar", 1386, 0.333333 cup], ["lemon juice", 1226, 1 tbs], ["virgin olive oil", 1361, 2 tsp], ["sugar", 1475, 1.5 tsp], ["salt", 1389, 1 tsp], ["pepper", 1390, 0.125 tsp], ["", "", 0.5 cup], ["shallot", 1101, 1], ["fresh parsley", 1448, 0.5 cup], ["fresh oregano", 1446, 1 tsp], ["almond", 1262, 3 tbs]]
def parse_ingredients(ingredient_array)

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
def add_recipe(original, name, intro, ingr_array, prepsteps, cooksteps, servings, preptime, cooktime, source, tags, skills, picture, approved)
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
  

#############################################################################  
## Parses recipe text file into Recipe DB
##

def parse_recipe(file_name, image_name)
  
  original = File.read(file_name)	
  
	## split the file contents into an array
	file_content_array = open_file(file_name)

  @recipe_name = file_content_array[0].chomp
	if Recipe.find_by_name(@recipe_name)
		puts "*** WARNING: Recipe with the same name as #{@recipe_name} found in dB, recipe not imported***"
		##update_recipe()
		
	else  ## import the recipe
    @intro = ""
		@ingredients = Array.new(size=0)
		@ingredients_parsed_array = Array.new
		@prepsteps = ""
		@cooksteps = ""
		@servings = nil
		@preptime = nil
		@cooktime = nil
		@source = ""
		@skills = ""
		@tags = nil
    
    @pic_file = image_name		
    counter = 1
    
    ## Iterate to look for keywords that divide the sections:
		## SERVINGS, WORKTIME, WAITTIME ##
		while counter < file_content_array.length
		  if (file_content_array[counter].include? "**intro**")
        counter = counter +1
        @intro = file_content_array[counter]
        #puts "found intro: #{@intro} \n"
      elsif (file_content_array[counter].include? "**ingredients**")
        i=0
        counter = counter + 1
        until (file_content_array[counter].include? "**") or (counter == file_content_array.size-1) do ##might be multiple lines under **ingredients
          @ingredients[i] = file_content_array[counter]
          i=i+1
          counter = counter +1
        end
        @ingredients_parsed_array = parse_ingredients(@ingredients) 
        #puts "Parsed ingredients: #{@ingredients_parsed_array.inspect}"
      elsif (file_content_array[counter].include? "**prep**") 
        counter = counter +1
        until (file_content_array[counter].include? "**") or (counter == file_content_array.size-1) do 
          @prepsteps = @prepsteps + file_content_array[counter] + "\n"
          counter = counter +1
        end
        #puts "Found Prep #{@prepsteps} \n"
      elsif (file_content_array[counter].include? "**cook**") 
        counter = counter +1
        until (file_content_array[counter].include? "**") or (counter == file_content_array.size-1) do 
          @cooksteps = @cooksteps + file_content_array[counter] + "\n"
          counter = counter +1
        end
        #puts "Found Cook #{@cooksteps} \n"
			elsif (file_content_array[counter].include? "**serves**")
				counter = counter +1
				@servings = file_content_array[counter].find_num 
				#puts "found servings: #{@servings} \n"
			elsif (file_content_array[counter].include? "**preptime**") 
				counter = counter +1
				@preptime = file_content_array[counter].delete "." " " "min"
				#puts "found preptime #{@preptime} \n"
			elsif (file_content_array[counter].include? "**cooktime**") 
				counter = counter +1
				@cooktime = file_content_array[counter].delete "." " " "min"
				#puts "found cooktime #{@cooktime} \n"   
			elsif (file_content_array[counter].include? "**source**") 
				counter = counter +1
				until (file_content_array[counter].include? "**") or (counter == file_content_array.size-1) do ##might be multiple lines under **source
					@source = @source + file_content_array[counter]
					counter = counter + 1
        end
        #puts "found source: #{@source} \n"   
      elsif (file_content_array[counter].include? "**skills**")
        counter = counter +1
        @skills = file_content_array[counter]
        #puts "found skills: #{@skills} \n"
      elsif (file_content_array[counter].include? "**tags**") 
        counter = counter +1
        @tags = file_content_array[counter]
        #puts "found tags: #{@tags} \n"   
      else 
				counter = counter +1
			end
		end

		## Adds recipe to DB
    recipe_id = add_recipe(original , @recipe_name, @intro, @ingredients_parsed_array, @prepsteps, @cooksteps, @servings, @preptime, @cooktime, @source, @tags, @skills, @pic_file,true)
    
		print "ID #{recipe_id} added for recipe #{@recipe_name}\n"
	end
end
#--

## Update this to the recipe import main
##
def replace_recipe_original(file_name)
  file_content_array = open_file(file_name)

  @title = file_content_array[0].chomp
  r = Recipe.find_by_name(@title)
  s = IO.read(file_name)
  r.original = s
  r.save! 
end
 
##############################################################################
##open files, parses files into ingredients, instructions, serving, worktime and waitime 


text_files_dir = "recipes/dec2011/"
images_dir ="public/assets/recipes/"

Dir.glob(text_files_dir+"*.txt") do |filename|
  
  puts ("*************** #{filename} ***************")
  
  ## Gets the image file name that matches the .txt name
  images_array = Dir.glob(images_dir+"*.jpg")
  name = filename.scan(/\/(\w+).txt/) 
  picfile = images_dir + name[0].to_s + ".jpg"
  ## See if image file exists in the same directory
  if images_array.include?(picfile)
    puts ("Image found: #{picfile}")
    parse_recipe(filename, name[0].to_s + ".jpg")
  else
  ##replace_recipe_original(filename)
    puts "Image not found."
    parse_recipe(filename, nil)
  end
end

