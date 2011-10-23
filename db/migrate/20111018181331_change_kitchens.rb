class ChangeKitchens < ActiveRecord::Migration
  def self.up
  	change_table :kitchens do |t|
  		t.integer :default_servings
  	end
  end

  def self.down
  	change_table :kitchens do |t|
  		t.remove :default_servings
  	end
  end
end
