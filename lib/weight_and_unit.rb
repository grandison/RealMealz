public

def weight_and_unit_name(units_only = false)
  weight_str = ''
  unit_str = ''
  name_str = ''
  
  unless weight.nil?
    # Ruby 1.9.3 needs the "to_f" otherwise it returns fractions like 40/100 for 0.4
    weight_str = weight.round(2).to_f.to_s.chomp('.0')
    weight_str = '1/4' if weight_str == '0.25'
    weight_str = '1/2' if weight_str == '0.5'
    weight_str = '3/4' if weight_str == '0.75'
    weight_str = '1/3' if weight_str == '0.33'
    weight_str = '2/3' if weight_str == '0.67'
  end
  
  unless unit.nil?
    unit_str = unit.dup.downcase
    # if unit is whole, see if there is a more precise unit in the ingredients whole_unit field
    if unit_str == 'whole' 
      if ingredient.whole_unit.blank?
        unit_str = ''
      else
        unit_str = ingredient.whole_unit.downcase
      end
    end

    unless weight.nil? || weight <= 1
      unit_str = unit_str.pluralize
    end
  end
  
  unless ingredient.nil? || ingredient.name.nil? || units_only
    name_str = ingredient.name
    # Pluralize the ingredient name if no unit, unless the plural hint indicates otherwise
    if unit_str.empty? && !weight.nil?
      if weight > 1 
        name_str = name_str.pluralize
      else 
        name_str = name_str.singularize
      end
    end
  end

  "#{weight_str} #{unit_str} #{name_str}".squeeze(' ').strip
end

