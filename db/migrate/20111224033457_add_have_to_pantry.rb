class AddHaveToPantry < ActiveRecord::Migration
  def self.up
    change_table :ingredients_kitchens do |t|
      t.boolean :have, :default => false
    end
  end

  def self.down
    change_table :ingredients_kitchens do |t|
      t.remove :have
    end    
  end
end
