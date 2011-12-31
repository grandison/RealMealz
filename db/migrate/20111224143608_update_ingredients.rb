class UpdateIngredients < ActiveRecord::Migration
  
  class Ingredient < ActiveRecord::Base
  end
  
  def self.up
     change_table :ingredients do |t|
        t.text :other_names, :default => ''
        t.string :whole_unit, :default => ''
        t.remove :description
      end
      
      Ingredient.reset_column_information
      Ingredient.transaction do
        Ingredient.all.each do |i|
          i.other_names = "|#{i.name}|#{i.name.pluralize}|"
          i.name = i.name.capitalize
          i.save!
        end
      end
  end

  def self.down
    change_table :ingredients do |t|
      t.text :description
      t.remove :other_names, :whole_unit
     end

     Ingredient.reset_column_information
     Ingredient.transaction do
       Ingredient.all.each do |i|
         i.name = i.name.downcase
         i.save!
       end
     end

  end
end
