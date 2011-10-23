class ChangeIngredientsRecipes < ActiveRecord::Migration
  def self.up
    change_table :ingredients_recipes do |t|
      t.string :group
    end
  end

  def self.down
    change_table :ingredients_recipes do |t|
      t.remove :group
    end
  end
end
