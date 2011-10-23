class DefaultDaysInKitchen < ActiveRecord::Migration
  def self.up
  	change_table :kitchens do |t|
  		t.string :default_meals
  	end
  end

  def self.down
  	change_table :kitchens do |t|
  		t.remove :default_meals
  	end
  end
end
