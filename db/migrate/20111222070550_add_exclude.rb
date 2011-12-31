class AddExclude < ActiveRecord::Migration
  def self.up
    change_table :ingredients_kitchens do |t|
      t.boolean :exclude, :default => false
    end    
  end

  def self.down
    change_table :ingredients_kitchens do |t|
      t.remove :exclude
    end    
  end
end
