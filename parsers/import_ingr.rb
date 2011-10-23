require "rubygems"
#require File.expand_path('../../config/environment', __FILE__)
require "ruby_ext"

## to run in console: load "parsers/import_ingr.rb"
#########################################################################
## Parse ingredients.txt and adds it to DB.  Automatically checks for duplicates of both
## categories and ingredient, and for relational duplicates
##
## Usage (at rails console): load "import_ingr.rb"
## Make sure filename.txt below is replaced with the intended .txt file
## Text file needs to be in following format:
=begin

Herbs
Rosemary, Thyme, Mint, parsley, bay leaf, basil, cilantro, chives, oregano,dill,dill weed,kaffir lime, kaffir lime leaves,sage,tarragon
marjoram
###

=end


myfile_array = Array.new
myfile_array = open_file("parsers/ingredients2.txt")
@i_array = Array.new
@c_array = Array.new


cnt = 0
while cnt != myfile_array.length
	@c_array = myfile_array[cnt].split(/,/).make_singular

	cnt=cnt+1
	until myfile_array[cnt].include?("###") or cnt == myfile_array.length-1
		@i_array = myfile_array[cnt].split(/,/).make_singular				

		## create loop to dump @c_array and @i_array into DB in right iteration.
		(0..@c_array.length-1).each do |cnt1|
			if @c_array[cnt1] != ""  ## make sure it is not an empty string
				@c = Category.find_by_name(@c_array[cnt1])
				if @c == nil  #Category doesn't exist, create new one.
					@c = Category.new
					@c.name = @c_array[cnt1]
					print "found new category: "
					print @c.name
					print "\n"
				end
							
			end

			(0..@i_array.length-1).each do |cnt2|
				if @i_array[cnt2] != ""
					@i = Ingredient.find_by_name(@i_array[cnt2]) #or use: .find(:first, :name => @i_array[cnt2])  
					if @i == nil  #if ingredient doesn't already exist, then
						@i = Ingredient.new
						@i.name = @i_array[cnt2]
						print "found new ingredient: "
						print @i.name
						print "\n"
					end
				end

				# Check if relation exists between categories and  ingredients, otherwise skip.
				if !@c.ingredients.include?(@i)

					print "New link created between "
					print @c.name
					print " and "
					print @i.name
					print "\n"
					@i.categories << @c
					@i.save					
				end


			end

		end

		@i_array=nil
		cnt=cnt+1
	end
	@c_array=nil
	cnt=cnt+1
end



