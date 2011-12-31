require "rubygems"

ActiveSupport::Inflector.inflections do |inflect|
	inflect.irregular "leaf", "leaves"
	inflect.irregular "couscous", "couscous"
	inflect.irregular "fajita","fajitas"
	inflect.irregular "pita","pitas"
	inflect.irregular "tortilla", "tortillas"
	
	inflect.uncountable %w(tofu oil brocoli pasta polenta paste)
	
	inflect.singular "cloves", "clove"
	inflect.singular "beans", "bean"
	inflect.singular "citrus", "citrus"
	inflect.singular "seedless","seedless"
	inflect.singular "ramen","ramen"
	inflect.singular "chiles","chili"
	inflect.singular "chilies","chili"
	inflect.singular "olives", "olive"
	inflect.singular "olive", "olive"
	inflect.singular "kalamata","kalamata"
	inflect.singular "milk", "milk"
	inflect.singular "soy", "soy"
	inflect.singular "yes", "yes"
	inflect.singular "fajitas", "fajitas"
	
	
	inflect.plural /^and$/,"and"
	inflect.plural /^in$/,"in"
	inflect.plural /^very$/,"very"
	inflect.plural /^milk$/,"milk"
	inflect.plural /^soy$/,"soy"
	inflect.plural /^wheat$/,"wheat"
	inflect.plural /^fish$/,"fish"
	inflect.plural /^shellfish$/,"shellfish"
	inflect.plural /^garlic$/,"garlic"
	inflect.plural /^oil$/,"oil"
	inflect.plural /^lamb$/,"lamb"
	inflect.plural /^beef$/,"beef"
	inflect.plural /^salmon$/,"salmon"
	inflect.plural /^cod$/,"cod"
	inflect.plural /^pork$/,"pork"
	inflect.plural /^garlic$/,"garlic"
	inflect.plural /^sauce$/,"sauce"
	inflect.plural /^udon$/,"udon"	
	inflect.plural /^cumin$/,"cumin"
	inflect.plural /^g$/,"g"
end

class String
  
  
  def capitalize_all
    return_string = ""
    array = self.split
    array.each do |element|
      return_string << element.capitalize << " "
    end
    return return_string
  end


	##############################################################################
	## 
	## Pluralizes each word in the sentence and  returns it.
	## Usage: "bean and bird".make_plural 

	def make_plural
		sentence_array=Array.new
		new_sentence_array=Array.new
		sentence_array= to_str.split(/ /)
			(0..sentence_array.size-1).each do |cnt|
				new_sentence_array << sentence_array[cnt].strip.downcase.pluralize
			end
		return new_sentence_array.join(" ")
	end

###############################################################################
## Finds closest string in front of the key_string
## Returns the found sub_string
## Usage: closest_string_in_front(whole_string, key_string, sub_string to be found)
## ie: closest_string_in_front("1 1/2 3 1/2 oz can chicken broth", 'oz',/\d+\s\d+\/\d+/)

	def closest_string_in_front(key_string, sub_string)

		positions = []
		last_pos = nil
		my_string = " " + to_str
		key_pos = my_string.index(key_string)
		if key_pos.nil?
			#puts "WARNING: closest_string_in_front PASSED A string THAT DID NOT INCLUDE key_string"
			return nil
		else
			my_string = my_string.slice(0..key_pos+1)
		end

		while (last_pos = my_string.index(sub_string, (last_pos ? last_pos + 1 : 0)))
			positions << last_pos
		end

		if positions != []
			return_string = my_string[key_pos-positions.map{|p| (p-key_pos).abs}.min..key_pos-1]
			return return_string.match(sub_string).to_s
		else
			return nil
		end
	end

	##############################################################################
	## Returns the closest number (complex fraction, simple fraction, decimal or number) in a string 
	## as a float 
	## Usage: fetched_number = line.find_closest_num
	##
	## 
	def find_closest_num (key)
		
		number=nil
	 	number_array = Array.new
		line = to_str
		
		## First try parsing for complex fractions (ie 3 1/4)
		number_holder = line.closest_string_in_front(key, /\s\d+\s\d+\/\d+/)		
		if !number_holder.nil?
			number_array = number_holder.scan(/(\d+)\s(\d+)\/(\d+)/)
			## operates to create float (ie 3+ 1/4)
			number = number_array[0][0].to_f + number_array[0][1].to_f / number_array[0][2].to_f  
			
		else
		##Parse for simple fractions (ie 1/4)
			number_holder = line.closest_string_in_front(key, /\s\d+\/\d+/)	
			if !number_holder.nil?
				number_array, temp =line.scan(/(\d+)\/(\d+)/)
				number = number_array[0].to_f / number_array[1].to_f  
				## assign if simple fraction is found
			else	
			## try parsing for decimals (ie 4.5)
				number_holder = line.closest_string_in_front(key, /\s\d+\.\d+/)			
				if !number_holder.nil?
					#number_array = line.scan(/\d+\.\d+/)  ## try parsing for decimals (ie 4.5)
					number = number_holder.strip ## assign if decimals found
				else
				##parse for just a number
					number_holder = line.closest_string_in_front(key, /\s\d+/)			
					if !number_holder.nil?
						number = number_holder.strip ## assign if found
					end
				end
			end
		end
		return number
	end
	
end