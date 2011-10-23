#require File.expand_path('../../config/environment', __FILE__)
#require "ruby_ext"

#############################################################################
## Open file and return content without empty lines in an array
## Returns: returnfile_content in array without empty lines
##

def open_file (filename)
  counter = 0
  returnfile_content = Array.new(size=0)
  file = File.new(filename, "r")
  while (line = file.gets)
    if !line.chomp.empty? 
      returnfile_content[counter]= "#{line.strip}"  
      counter = counter + 1
    end
  end
  return returnfile_content
  file.close
rescue => err
  #puts "Exception: #{err}"
  err
end


=begin
#################3333
## Doesn't work yet, still testing
def find_jpg_pic_name(filename)
  filename_array = filename.scan(/(\w+).txt/) 
  filename_only = filename_array[0][0]
  #puts Dir.entries("C:/connie/Workspace/RealMealz/public/assets/recipes").inspect
  Dir.entries("C:/connie/Workspace/RealMealz/public/assets/recipes").each do |line|
    array = line.scan(/(\w+).jpg/).inspect
    if !array.nil? 
      dir_filename_only = array[0][0]
      if dir_filename_only == (filename_only)
        return "#{filename_only}.jpg"
      end
    end
  end
  return nil
end

puts find_jpg_pic_name("C:/abc/dkf/rm_vegetarian_spaghetti.txt")

##############################################################################
## Finds the filename of the picture in either .jpg or .png given the .txt name of the recipe
## The filename has to match the .txt filename
## Usage: picture_name = find_pic("recipes/test/watermelon_salsa.txt")
##

def find_pic(txt_file_name, image_path)
  
  directory_depth = Array.new
	dir_array = Array.new
	filename_array = Array.new
	pic_name = nil
	found = 0
	
	filename_array = full_file_name.scan(/(\w+).txt/) 
	filename_only = filename_array[0][0]
	#puts filename_only.inspect

	directory_depth = full_file_name.split(filename_only)
	#puts directory_depth.inspect
	#puts filename_only

	
	dir_array = Dir.entries(directory_depth[0])
	
	(0..dir_array.length-1).each do |cnt|
		if dir_array[cnt] == "#{filename_only}.jpg" 
			pic_name = "#{filename_only}.jpg" 
			found = 1
		elsif	dir_array[cnt] == "#{filename_only}.JPG" 
			pic_name = filename_only + ".jpg" 
			found = 1
		elsif dir_array[cnt] == "#{filename_only}.png" 
			pic_name = "#{filename_only}.png" 
			found = 1
		elsif dir_array[cnt] == "#{filename_only}.PNG"  
			pic_name = "#{filename_only}.PNG" 
		#	pic_name = #directory_depth[0]+dir_array[cnt] 
			found = 1
		end
		
	end

	return pic_name
end
=end
#puts find_pic("recipes/test/watermelon_salsa.txt")
