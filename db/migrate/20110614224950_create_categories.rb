class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string :name
    end
    
    create_table :categories_ingredients, :id => false do |t|
      t.integer :category_id
      t.integer :ingredient_id
    end
  end

  def self.down
    drop_table :categories_ingredients
    drop_table :categories
  end
end
