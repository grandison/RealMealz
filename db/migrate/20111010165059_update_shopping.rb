class UpdateShopping < ActiveRecord::Migration
  def self.up
    change_table :ingredients_kitchens do |t|
      t.remove :shop_checkbox_state
      t.remove :on_shop_list, :starred
      t.remove :shop_weight
      t.remove :shop_unit, :shop_order, :pantry_order
      t.boolean :needed, :bought
    end

    change_table :kitchens do |t|
      t.text :pantry_order, :shop_order
    end

  end

  def self.down
    change_table :kitchens do |t|
      t.remove :pantry_order, :shop_order
    end

    change_table :ingredients_kitchens do |t|
      t.remove :needed, :bought
      t.string :shop_unit, :shop_order, :pantry_order
      t.float :shop_weight
      t.boolean :on_shop_list, :starred
      t.integer :shop_checkbox_state
    end
  end
end
