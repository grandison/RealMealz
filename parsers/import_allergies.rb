require "rubygems"
#require File.expand_path('../../config/environment', __FILE__)
require "ruby_ext"

#########################################################################
## Parse allergies.txt and adds it to DB.  
## Automatically checks for duplicates 
##
## Usage (at rails console): load "parsers/import_allergies.rb"
## Make sure filename.txt below is replaced with the intended .txt file
## Text file needs to be in following format:  The ,yes denotes that it should be displayed (yes in the Allergy.display column
=begin
Peanut
Arachic oil, yes
Arachis
Arachis hypogaea
Beer nuts, yes
Goober peas, yes
Goobers
Hypogaeic acid
Mandelonas

###

=end


myfile_array = Array.new
myfile_array = open_file("parsers/allergies.txt")
@i_array = Array.new 

cnt = 0
while cnt != myfile_array.length
	@c = Allergy.find_by_name(myfile_array[cnt].make_singular)
	if @c.nil?  #Allergy doesn't exist, create new one.
		@c = Allergy.new
		@c.name = myfile_array[cnt].make_singular
		@c.display = "yes"
		print "found new parent allergy: "
		print @c.name
		print "\n"
		@c.save
	end
	cnt=cnt+1
	until myfile_array[cnt].include?("###") or cnt == myfile_array.length-1
		##  dump @c_array and @i_array into DB in right iteration.
		@i_array = myfile_array[cnt].split(/,/).make_singular				
		@i = Allergy.find_by_name(@i_array[0])
		if @i == nil and !@i_array[0].nil? #Allergy doesn't exist, create new one if name not nil
			@i = Allergy.new
			@i.name = @i_array[0]
			@i.parent_id = @c.id
			
			if @i_array[1].nil? 
				@i.display = "no"
			else
				if @i_array[1].include?("y")
					@i.display = "yes"
				else
					@i.display = "no"
				end
			end
			print "found new allergy: "
			print @i.name
			print "\n"
			@i.save
		end
		@i_array=nil
		cnt=cnt+1
	end
	cnt=cnt+1
end

