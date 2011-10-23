#require "rubygems"
#require "ruby-units"

class Unit < Numeric
  

  @@USER_DEFINITIONS = {
  '<whole>'=> [%w{whole}, 1, :counting, %w{<each>}],
    
  '<cup>'=> [%w{cup cups cu c}, 0.000236588238, :volume, %w{<meter> <meter> <meter>}],
  '<teaspoon>'=> [%w{tsp teaspoon teaspoons}, 4.92892161e-6, :volume, %w{<meter> <meter> <meter>}],
  '<tablespoon>'=> [%w{tbs tbsp tbsps tablespoon tablespoons}, 1.47867648e-5, :volume, %w{<meter> <meter> <meter>}],
  '<fluid-ounce>'=> [%w{oz fluid-ounce floz ounce ounces}, 2.95735297e-5, :volume, %w{<meter> <meter> <meter>}],
  '<liter>' => [%w{L l liter liters litre litres}, 0.001, :volume, %w{<meter> <meter> <meter>}], 
  '<milliliters>' => [%w{ml ML milliliters millilitres}, 1, :volume, %w{<meter> <meter> <meter>}], 
  '<gallon>'=> [%w{gal gallon gallons}, 0.0037854118, :volume, %w{<meter> <meter> <meter>}], 
  '<quart>'=> [%w{qt quart quarts}, 0.00094635295, :volume, %w{<meter> <meter> <meter>}], 
  '<pint>'=> [%w{pt pint pints}, 0.000473176475, :volume, %w{<meter> <meter> <meter>}],

  '<clove>' => [%w{clove cloves}, 2.42892161e-6, :volume, %w{<meter> <meter> <meter>}],  #clove = 1/2 teaspoon
#  '<pinch>'=> [%w{pinch pinches}, 1.22892161e-6, :volume, %w{<meter> <meter> <meter>}],	          #pinch = 1/4 teaspoon
  '<bunch>'=> [%w{bunch bunches}, 0.000354882357, :volume, %w{<meter> <meter> <meter>}],  #bunch = 1.5 cups
  '<handful>'=> [%w{handful handfuls}, 0.000354882357, :volume, %w{<meter> <meter> <meter>}], #handful = 1.5 cups
 	'<slice>'=> [%w{slice slices}, 4.92892161e-6, :volume, %w{<meter> <meter> <meter>}], #slice = 1 teaspoon
	'<sprigs>'=> [%w{sprig sprigs}, 1.21442161e-6, :volume, %w{<meter> <meter> <meter>}], #sprig = 1/4 teaspoon
 
  '<pound-volume>' => [%w{lbs lb pound pounds #}, 0.45359237, :mass, %w{<kilogram>}],
  '<gram>' => [%w{g gram grams gramme grammes},1e-3,:mass, %w{<kilogram>}],
  '<kilogram>' => [%w{kg kilogram kilograms}, 1.0, :mass, %w{<kilogram>}]
  
  }

	Unit.setup  
  
  def add(element)
    return self + element
  end
  
  def get_unit
  	return @unit_name
  end
  
  def get_scalar
  	return @scalar
  end
  
  ################
  ## Lets you round to any digits
  ## called by Shop .html.erb page
  def round_special(digits)
   # return @scalar.round(digits) 
    #if self.unitless?
      Unit.new(@scalar.round(digits), @numerator, @denominator)    
    #end
  end
  
  ##########################################################################################################3
  ## Converts from grams to cup for specific types of food, returns result but does not modify variable
  ## usage: convertedVAR = originalVAR.convert_g_to_cup("water")
  ## example:
  
  # connie = Unit.new("25000/100g")  #250g = 1 cup
 	# connie_cup = Unit.new("#{connie.convert_g_to_cup("water")} cup")
 	# max = Unit.new("21/2c")
 	# together = max + connie_cup
	# puts max
 	# puts connie
 	# puts connie_cup
	# puts together
	
	##
  def get_food_converter
    return Hash[     
    # Source: http://wiki.answers.com/Q/How_many_grams_are_in_a_cup#ixzz1PTnArx00
      "butter" => 225,   #1cup = 225 g  # 1 cup = 0.00023658824 meters^3  #1000g = 1kg
      "flour" => 110,
      "sugar" => 225,
      "brown sugar" => 220,
      "sifted flour" => 125,
      "rice" => 185,
      "almonds" => 108,
      "oil" => 224,
      "syrup" => 322,
      "milk" => 245,
      "broccoli" => 71,
      "raisins" => 165,
      "milk powder" => 68,
      "cocoa" => 125,
      "water" => 236,
      "liquid" => 236,
      "yogurt" => 245,
      "default" => 200
      ]   
  end
  
	#########################################################33
	## converts Unit to volume base (m^3) if it is in g or kg.  Otherwise keep it the same
	## Usage: Unit.new("3 kg").convert_to_volume   ==> 15 cups    
	def convert_to_volume(type = "default") 
    food_converter = get_food_converter
    food_converter.default = 200
    if self.to_base.get_unit == "kg"
      one = self.to("g")
      return Unit.new((one.get_scalar / food_converter[type]).to_s + " " + "cup")
    elsif self.to_base.get_unit == "each"
      return Unit.new(self.get_scalar.to_s + " cup") ## PLEASE FIX: need to convert to cup based on type (like zucchini, vs onion, vs carrots, vs etc.)
    else
      return self # possible cases: == "m^3"  
    end
  end
end



