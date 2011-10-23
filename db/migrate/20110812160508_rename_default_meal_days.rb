class RenameDefaultMealDays < ActiveRecord::Migration
  def self.up
  	change_table :kitchens do |t|
  		t.rename :default_meals, :default_meal_days
  	end
  end

  def self.down
  	change_table :kitchens do |t|
  		t.rename :default_meal_days, :default_meals
  	end
  end
end
