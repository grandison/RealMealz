class UpdateMeals < ActiveRecord::Migration
  def self.up
     change_table :meals do |t|
        t.rename :scheduled_date, :eaten_on
        t.remove :is_eaten, :meal_type_id
        t.boolean :my_meals, :starred, :default => false
      end
  end

  def self.down
    change_table :meals do |t|
      t.rename :eaten_on, :scheduled_date 
      t.boolean :is_eaten
      t.integer :meal_type_id
      t.remove :my_meals, :starred
    end
  end
end
