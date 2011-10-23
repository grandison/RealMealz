class MealOrder < ActiveRecord::Migration
  def self.up
    change_table :kitchens do |t|
      t.text :meal_order
    end
  end

  def self.down
    change_table :kitchens do |t|
      t.remove :meal_order
    end
  end
end
