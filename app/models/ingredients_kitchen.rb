class IngredientsKitchen < ActiveRecord::Base
  belongs_to :kitchen
  belongs_to :ingredient
  validates_presence_of :kitchen, :ingredient
  scope :needed, where("needed = true")
  require 'weight_and_unit'
  
  #-------------------
  def name
    weight_and_unit_name
  end

  #-------------------
  def weight_and_units
    weight_and_unit_name(units_only = true)
  end
  
  #-------------------
  # This is needed for JSON conversions
  def ingredient_name
    return ingredient.name
  end

  #-------------------
  def shop_name
    line = ''
    if bought
      line << '[X] '  
    else
      line << '[ ] '
    end
    line << ingredient.name
    unless weight.blank? || weight.zero? || unit.nil?
      line << " (#{weight_and_units}) "
    else
      line << ", " unless note.blank?
    end
    line << note unless note.blank?
    return line
  end
  
  
end
