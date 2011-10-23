class CreateIngredientsKitchens < ActiveRecord::Migration
  def self.up
    create_table :ingredients_kitchens do |t|
			t.integer :kitchen_id
			t.integer :ingredient_id
			t.float	 	:weight
			t.string 	:unit
    end
  end

  def self.down
    drop_table :ingredients_kitchens
  end
end
