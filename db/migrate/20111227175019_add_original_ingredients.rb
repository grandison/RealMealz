class AddOriginalIngredients < ActiveRecord::Migration
  def self.up
    change_table :recipes do |t|
      t.rename :ingredient_list, :original_ingredient_list
    end    
    
    change_table :ingredients_recipes do |t|
      t.string :description, :default => ''
    end
  end

  def self.down
    change_table :recipes do |t|
      t.rename :original_ingredient_list, :ingredient_list
    end
        
    change_table :ingredients_recipes do |t|
      t.remove :description
    end
  end
end
