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
        @ingredients_parsed_array = Recipe.parse_ingredients(@ingredients) 
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
			elsif (file_content_array[counter].include? "**tags**") 
        counter = counter +1
        @tags = file_content_array[counter]
        #puts "found tags: #{@tags} \n"   
      elsif (file_content_array[counter].include? "**skills**")
        counter = counter +1
        @skills = file_content_array[counter]
        #puts "found skills: #{@skills} \n"
			else 
				counter = counter +1
			end
		end

		## Adds recipe to DB
    recipe_id = Recipe.add_recipe(original , @recipe_name, @intro, @ingredients_parsed_array, @prepsteps, @cooksteps, @servings, @preptime, @cooktime, @source, @tags, @skills, @pic_file,"no")
    
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


Dir.glob("recipes/*.txt") do |filename|
  puts ("*************** #{filename} ***************")
  
  ## Gets the image file name that matches the .txt name
  images_array = Dir.glob("recipes/*.jpg")
  name = filename.scan(/\/(\w+).txt/) 
  picfile = "recipes/" + name[0].to_s + ".jpg"
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

