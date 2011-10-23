class IngredientAllergen < ActiveRecord::Migration
  def self.up
   change_table :ingredients do |t|
	     t.integer :allergen1_id, :allergen2_id, :allergen3_id
   end
  end

  def self.down
   change_table :ingredients do |t|
	     t.remove :allergen1_id, :allergen2_id, :allergen3_id
   end
  end
end
