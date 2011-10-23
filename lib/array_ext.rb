class Array

	##############################################################################
	## 
	## Chomps, Downcases and Singularizes each element in the array using str.make_singular and returns the array.
	## Usage: ary.make_singular

	def make_singular
		new_array = Array.new
		(0..self.size-1).each do |cnt|
			element = self[cnt]
			if element == ""
				element = nil
			end
			if !element.nil?
				new_array << element.strip.downcase.singularize			
			end
		end
		return new_array
	end
end


