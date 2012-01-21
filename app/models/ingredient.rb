class Ingredient < ActiveRecord::Base
	
  has_many :categories_ingredients
  has_many :categories, :through => :categories_ingredients, :source => :category
  has_many :ingredients_recipes
  has_many :recipes, :through => :ingredients_recipes, :source => :recipe  
  
  belongs_to :allergen1, :class_name => 'Allergy', :foreign_key => "allergen1_id"
  belongs_to :allergen2, :class_name => 'Allergy', :foreign_key => "allergen2_id"
  belongs_to :allergen3, :class_name => 'Allergy', :foreign_key => "allergen3_id"
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :kitchen_id
  
  #--------------------------------------
  def get_balance_category
    self.categories.map {|c| if c.name == "protein"
        return :protein
    elsif c.name == "vegetable"
        return :vegetable
    elsif c.name == "fruit"
        return :fruit
    elsif c.name == "starch"
        return :starch
    end}
  end
  
	#--------------------------------------
  ##  Adds an allergen_id to the allergen_id list of an ingredient if it's not already there
  ##  Usage: i.add_allergen(allergy.id)
  ##  Used by: parsers/update_ingr_allergens.rb
  ##	
	def add_allergen(allergen_id)
    ## check to make sure it's not already in there
    if (self.allergen1_id != allergen_id) and (self.allergen2_id != allergen_id) and (self.allergen3_id != allergen_id)
      # not in there, put in earliest spot:
      if self.allergen1_id.nil?
        self.allergen1_id = allergen_id
        self.save!
        return "linking #{self.name} to allergen #{allergen_id} in slot 1"
      elsif self.allergen2_id.nil?
        self.allergen2_id = allergen_id
        self.save!
        return "linking #{self.name} to allergen #{allergen_id} in slot 2"
      elsif
        self.allergen3_id.nil?
        self.allergen3_id = allergen_id
        self.save!
        return "linking #{self.name} to allergen #{allergen_id} in slot 3"
      end
    end
	end
	
  #############
  # Class methods
  #############

	#--------------------------------------
	# make sure that the other_names field is filled, otherwise searches by name won't work
	def self.new(attributes = nil, options = {})
	  if !attributes.nil? && attributes[:other_names].blank? && !attributes[:name].blank?
	    attributes[:other_names] = "|#{attributes[:name].downcase}|" 
    end
	  super
  end

	#--------------------------------------
	def self.find_or_create_by_name(name, kitchen_id, attribs = {})
	  return nil if name.blank?
    search_name = name.strip.downcase
    if kitchen_id.blank? || kitchen_id.zero?
      ingr = where("other_names LIKE ? AND (kitchen_id IS NULL OR kitchen_id = 0)", "%|#{search_name}|%").first
    else
      ingr = where("other_names LIKE ? AND (kitchen_id = ? OR kitchen_id IS NULL OR kitchen_id = 0)", "%|#{search_name}|%", kitchen_id).first
    end
    if ingr.nil?
      ingr = create({:name => name.strip.capitalize}.merge(attribs))
      ingr.kitchen_id = kitchen_id
      ingr.save!
    end
    return ingr
  end
  
	#--------------------------------------
  def self.find_or_create_by_name_or_id(ingredient_name_or_id, kitchen_id, attribs = {})
    if ingredient_name_or_id.is_a?(String)
      find_or_create_by_name(ingredient_name_or_id, kitchen_id, attribs)
    else
      find(ingredient_name_or_id)
    end
  end

  #--------------------------------------
  # Returns an array of hashes containing the ingredient possible names (from other_names) and ids, 
  # sorted from longest to shortest name
	def self.create_hash_by_name_length
		ingr_sort_hash = find(:all).map do |ingr|
		  next if ingr.other_names.blank?
		  
		  ingr.other_names.split("|").map  do |other_name|
		    next if other_name.blank?
		    {:name => other_name, :id => ingr.id}
	    end
	  end
	  ingr_sort_hash.flatten.delete_if {|h| h.nil?}.sort { |x, y| y[:name].length <=>  x[:name].length }
	end

  #--------------------------------------
  def self.combine_ingredients(ingr_combine, ingr_main)
    ingr_main.other_names = "|#{ingr_main.other_names}|#{ingr_combine.other_names}|".squeeze("|")
    ingr_main.save!

    IngredientsKitchen.where(:ingredient_id => ingr_combine.id).update_all(:ingredient_id => ingr_main.id)
    IngredientsRecipe.where(:ingredient_id => ingr_combine.id).update_all(:ingredient_id => ingr_main.id)
    CategoriesIngredient.where(:ingredient_id => ingr_combine.id).update_all(:ingredient_id => ingr_main.id)

    ingr_combine.delete
  end

  #------------------------- 
  # This is mainly used for testing
  def self.reset_cache
    @ingr_hash = nil
  end
  
  #------------------------- 
  # Get all the ingredients, then sort by length - longest first. Cache this for performance
  # Next go through all these ingredients and see if any match the ingredient line
  # If so, then go back to the DB and get the ingredient and then create and link the ingredient_recipe
  # Finally take out the ingredient from the line
  # 
  # Line should be downcased before entering
  def self.find_name_and_create(line)
    @ingr_hash ||= Ingredient.create_hash_by_name_length
    ingr_index = @ingr_hash.index {|ingr| line.include?(ingr[:name])}

    if ingr_index.nil?
      return Ingredient.find_or_create_by_name('(unknown)', nil)
    end
    
    line.slice!(@ingr_hash[ingr_index][:name])

    return Ingredient.find(@ingr_hash[ingr_index][:id])
  end
  
  #------------------------- 
  # Look for units, longest first
  # Requires a space after the unit name in the line, otherwise will match parts of other words
  def self.find_unit(line)
    unit_name = 'whole'
    Ingredient.unit_names.each do |unit_hash|
      if indx = line.index(unit_hash[:alias] + ' ')
        unit_name = unit_hash[:name]
        line.slice!(indx, unit_hash[:alias].length)
        break
      end
    end
    return unit_name
  end
  
  #------------------------- 
  # Returns the first number (complex fraction, simple fraction, decimal or number)
  # as a float 
  # First searches for the number without groups because we need the original string to
  # eliminate it from line. 
  def self.find_num(line)
    num = nil

    ## First try parsing for complex fractions (ie 3 1/4)
    num_str = line.scan(/\d+\s\d+\/\d+/)[0]
    if !num_str.blank?
      num_array = num_str.scan(/(\d+)\s(\d+)\/(\d+)/)[0]
      num = num_array[0].to_f + num_array[1].to_f / num_array[2].to_f 
    else
      num_str = line.scan(/\d+\/\d+/)[0]  ##Parse for simple fractions (ie 1/4)
      if !num_str.blank?
        num_array = num_str.scan(/(\d+)\/(\d+)/)[0]  
        num = num_array[0].to_f / num_array[1].to_f
      else	
        num_str = line.scan(/\d+\.\d+/)[0]  ## try parsing for decimals (ie 4.5)
        if !num_str.blank?
          num = num_str.to_f
        else
          num_str = line.scan(/\d+/)[0]  ## try parsing for just a number  
          if !num_str.blank?
            num = num_str.to_f
          end
        end
      end
    end
    if num.nil?
      return nil 
    else
      line.slice!(num_str)
      return num
    end
  end
  
  #------------------------- 
  # Take what is left and clean it up by removing floating commas and extra spaces
  def self.find_description(line)
    return line.gsub(" ,", ",").strip.gsub(/^,|,$/, "").squeeze(" ").strip
  end

  #------------------------- 
  # The first name of each line is the name we want to use, the rest are other names to look for that refer to this unit
  UNIT_NAMES = [
    %w(cup cups c. cu),
    %w(tsp tsps teaspoon teaspoons t.),
    %w(tbs tablespoon tablespoons),
    %w(lbs lb pound pounds),
    %w(oz ozs oz. ounce ounces),
    %w(whole clove cloves bunch bunches handful handfuls pinch pinches slice slices sprig sprigs),
    %w(pint pints),
    %w(quart quarts),
    %w(gallon gallons gal),
    %w(gram grams g),
    %w(ml mls mL mLs milliliter milliliters millilitre millilitres),
    %w(liter liters litre litres),
  ]
  def self.unit_names
    # Construct an array that makes it easy to find the units
    # Do this by expanding the UNIT_NAMES so that all possible names with the 
    # corresponding unit are together and the array is sorted with longest names first
    # Cache this for performance
    if @unit_names.nil?
      @unit_names = []
      UNIT_NAMES.each do |names|
        names.each do |name|
          @unit_names << {:name => names[0], :alias => name}
        end
      end
      
      @unit_names = @unit_names.sort {|c1, c2| (c2[:alias].length != c1[:alias].length)? c2[:alias].length <=> c1[:alias].length : c1[:alias] <=> c2[:alias]}
    end
    return @unit_names
  end
  
  #------------------------- 
  UNIT_CONVERSIONS = {}
  UNIT_CONVERSIONS['pint'] = {'factor' => 2.0, 'unit' => 'cup'}
  UNIT_CONVERSIONS['quart'] = {'factor' => 4.0, 'unit' => 'cup'}
  UNIT_CONVERSIONS['gallon'] = {'factor' => 16.0, 'unit' => 'cup'}
  UNIT_CONVERSIONS['gram'] = {'factor' => 0.0352, 'unit' => 'oz'}
  UNIT_CONVERSIONS['ml'] = {'factor' => 0.0676, 'unit' => 'tbs'}
  UNIT_CONVERSIONS['liter'] = {'factor' => 4.23, 'unit' => 'cup'}
  
  def self.standardize_unit(ingredient_recipe)
    if conversion = UNIT_CONVERSIONS[ingredient_recipe.unit]
      if ingredient_recipe.weight.nil?
        weight = 0
      else
        weight = ingredient_recipe.weight * conversion['factor']
      end
      ingredient_recipe.update_attributes!(:weight => weight, :unit => conversion['unit'])
    end
  end
	
end
