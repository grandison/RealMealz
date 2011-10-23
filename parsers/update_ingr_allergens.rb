require "rubygems"
require "ruby_ext"
#require File.expand_path('../../config/environment', __FILE__)

###################
## Dupliated methods here so that this script works

def get_parent_allergy_names
  Allergy.find(:all, :conditions => {:parent_id => nil}).map {|a| a.name}
end

def get_parent_allergies
  Allergy.find(:all, :conditions => {:parent_id => nil})
end


########## to run in console: load "parsers/update_ingr_allergens.rb"
#########################################################
## Quickly links allergy_id to ingredients list based on category and sub_string matches using include?
##

get_parent_allergies.each do |allergy|
  c = Category.find_by_name(allergy.name)
  puts "allergy id #{allergy.id} is #{allergy.name}"
  if !c.nil?  #assign allergen in ingredient table if ingredient fits allergy category
    c.ingredients.each do |i|
      line =  i.add_allergen(allergy.id)
      if !line.nil?
        puts line
      end
    end
  end
  Ingredient.find(:all).each do |ingre|
  ## check if ingredient.name includes the allergen name, if so, assign allergen.
    if ingre.name.to_s.include?(allergy.name.to_s) 
      line = ingre.add_allergen(allergy.id)
      if !line.nil?
        puts line
      end
    end
  end
end

 