class CreateSortOrders < ActiveRecord::Migration
  def self.up
    create_table :sort_orders do |t|
  		t.references :kitchen
  		t.string :tag
  		t.text :order
  	end    
  	
  	change_table :kitchens do |t|
      t.remove :meal_order, :pantry_order, :shop_order
    end
  end

  def self.down
  	change_table :kitchens do |t|
      t.text :meal_order, :pantry_order, :shop_order
    end
    
    drop_table :sort_orders
  end
end
