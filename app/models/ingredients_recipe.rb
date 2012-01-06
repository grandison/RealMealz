class IngredientsRecipe < ActiveRecord::Base
  belongs_to :recipe, :include => :ingredients
  belongs_to :ingredient
  default_scope :order => 'line_num ASC'
  require 'weight_and_unit'

  #-------------------
  def name
    if group?
      return "*#{description}*"
    else
      return weight_and_unit_name
    end
  end

  #-------------------
  def name_and_description
    if group?
      return name
    elsif description.blank?
      return name
    else
      if name.blank?
        return description
      else
        return name + ", " + description
      end
    end
  end

end
