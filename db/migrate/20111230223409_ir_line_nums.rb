class IrLineNums < ActiveRecord::Migration
  def self.up
    change_table :ingredients_recipes do |t|
      t.integer :line_num
    end    
    change_column :ingredients_recipes, :group, :boolean, :default => false
  end

  def self.down
    change_column :ingredients_recipes, :group, :string
    change_table :ingredients_recipes do |t|
      t.remove :line_num
    end    
  end
end
