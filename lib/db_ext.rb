#require "rubygems"
#require File.expand_path('../config/environment', __FILE__)
#require "file_ext"
#require "string_ext"
#require "array_ext"


##############################################################################
## Returns an array containing the ingredients, and sorted from longest to shortest
## from the DB's Ingredient table 
## Usage: my_array = get_db_ingredients
##
def get_db_ingredients
	i_array = Array.new
	i_array = Ingredient.find(:all).map {|i| i.name}
	i_array.sort! { |x, y| y.length <=>  x.length }
	#puts i_array.pop
	#puts i_array.class
	#puts i_array.inspect
	#puts "hello"
	return i_array
end