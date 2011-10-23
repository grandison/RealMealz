class IngredientsAddKitchenId < ActiveRecord::Migration
  def self.up
  	change_table :ingredients do |t|
  		t.integer :kitchen_id
  	end
  end

  def self.down
  end
end
