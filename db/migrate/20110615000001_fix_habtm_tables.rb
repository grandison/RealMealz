class FixHabtmTables < ActiveRecord::Migration
  def self.up
    rename_table :member_branches, :branches_members
    rename_table :member_preferences, :members_preferences
    rename_table :meal_recipes, :meals_recipes
    rename_table :recipe_ingredients, :ingredients_recipes
    rename_table :kitchen_appliances, :appliances_kitchens
    rename_table :branch_products, :branches_products
    
    drop_table :categories_ingredients rescue nil
    create_table :categories_ingredients do |t|
      t.references :category, :ingredient
    end
  end

  def self.down
    rename_table :branches_products, :branch_products
    rename_table :appliances_kitchens, :kitchen_appliances
    rename_table :ingredients_recipes, :recipe_ingredients
    rename_table :meals_recipes, :meal_recipes
    rename_table :members_preferences, :member_preferences
    rename_table :branches_members, :member_branches 
  end
end
