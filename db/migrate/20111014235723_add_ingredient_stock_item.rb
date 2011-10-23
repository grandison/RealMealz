class AddIngredientStockItem < ActiveRecord::Migration
  def self.up
    change_table :ingredients do |t|
      t.boolean :stock_item, :default => false
    end
    Ingredient.reset_column_information

    ['Ketchup','Mustard','Olive oil','Bread','breadcrumbs','Salt','Pepper','Sugar',
      'cinnamon','Onions','Oatmeal','Italian Seasoning','BBQ Sauce','Milk','Peanut butter',
      'Corn Flakes','Pickles','Canned Beans',' Dry Pasta','Vinegar'].each do |name|
        i = Ingredient.find_by_name(name.downcase)
        unless i.nil?
          i.stock_item = true
          i.save!
        end
   end
 end

  def self.down
    change_table :ingredients do |t|
      t.remove :stock_item
    end
  end
end
