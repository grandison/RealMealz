class PantryTableUpdate < ActiveRecord::Migration
  def self.up
  	change_table :ingredients_kitchens do |t|
  		t.boolean	:starred
  		t.text 		:note  		
  		t.string 	:pantry_order
  		t.string	:shop_order
  		t.boolean	:on_shop_list
			t.float		:shop_weight
			t.string	:shop_unit
			t.integer	:shop_checkbox_state
  	end
  end

  def self.down
  end
end
