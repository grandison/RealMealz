class Ingredient < ActiveRecord::Base
	#set_table_name "ingredients"
	
  has_many :categories_ingredients
  has_many :categories, :through => :categories_ingredients, :source => :category
  has_many :ingredients_recipes
  has_many :recipes, :through => :ingredients_recipes, :source => :recipe  
  
  belongs_to :allergen1, :class_name => 'Allergy', :foreign_key => "allergen1_id"
  belongs_to :allergen2, :class_name => 'Allergy', :foreign_key => "allergen2_id"
  belongs_to :allergen3, :class_name => 'Allergy', :foreign_key => "allergen3_id"
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
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
  ## Returns an array containing the ingredient names, and sorted from longest to shortest
  ## from the DB's Ingredient table 
  ## Usage: Ingredient.get_names
  ## Used by "parsers/upate_ingr_allergens.rb"
	def self.sort_by_length
		find(:all).map {|i| i.name}.sort { |x, y| y.length <=>  x.length }
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
      else
        if self.allergen2_id.nil?
          self.allergen2_id = allergen_id
          self.save!
          return "linking #{self.name} to allergen #{allergen_id} in slot 2"
        else
          if self.allergen3_id.nil?
            self.allergen3_id = allergen_id
            self.save!
            return "linking #{self.name} to allergen #{allergen_id} in slot 3"
          end
        end
      end
    end
	end
	
	#--------------------------------------
	def display_name
    self.name.capitalize
  end
  
end
