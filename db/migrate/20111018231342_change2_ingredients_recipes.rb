class Change2IngredientsRecipes < ActiveRecord::Migration
  def self.up
    change_table :ingredients_recipes do |t|
      t.rename :units, :unit
    end
  end

  def self.down
    change_table :ingredients_recipes do |t|
      t.rename :unit, :units
    end
  end
end
