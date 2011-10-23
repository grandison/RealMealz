class Initial < ActiveRecord::Migration
  def self.up
    create_table :members do |t|
      t.string :first, :last, :email, :street, :city, :state, :zip
      t.boolean :is_admin
      t.string :login, :password
      t.references :kitchen
    end
    
    create_table :member_preferences do |t|
      t.integer :level
      t.references :member
      t.references :preference, :polymorphic => {:default => 'SlidingScale'}
    end
    
    create_table :member_branches do |t|
      t.float :distance
      t.integer :preference
      t.references :member, :branch
    end
    
    create_table :meals do |t|
      t.boolean :is_eaten
      t.datetime :scheduled_time
      t.references :kitchen, :meal_type 
    end
    
    create_table :meal_types do |t|
      t.string :name 
    end
    
    create_table :meal_recipes do |t|
      t.float :servings
      t.references :meal, :recipe
    end
    
    create_table :recipes do |t|
      t.string :name
      t.binary :picture
      t.text :instructions 
    end
    
    create_table :ingredients do |t|
      t.string :name
    end
    
    create_table :recipe_ingredients do |t|
      t.float :weight
      t.string :units, :important, :strength
      t.references :ingredient, :recipe
    end
    
    create_table :kitchens do |t|
      t.string :name
    end
    
    create_table :appliances do |t|
      t.string :name
    end
    
    create_table :kitchen_appliances do |t|
      t.references :appliance, :kitchen
    end
    
    create_table :stores do |t|
      t.string :name, :street, :city, :state, :zip, :phone, :website, :email
    end
    
    create_table :branches do |t|
      t.string :name, :street, :city, :state, :zip, :phone, :website, :email
      t.references :store
    end
    create_table :products do |t|
      t.string :name
    end
    
    create_table :branch_products do |t|
      t.references :product, :branch
      t.integer :on_hand
      t.string :location
    end
    
  end
  
  def self.down
    drop_table :members
    drop_table :member_preferences
    drop_table :member_branches
    drop_table :meals
    drop_table :meal_types
    drop_table :meal_recipes
    drop_table :recipes
    drop_table :ingredients
    drop_table :recipe_ingredients
    drop_table :kitchens
    drop_table :appliances
    drop_table :kitchen_appliances
    drop_table :stores
    drop_table :branches
    drop_table :products
    drop_table :branch_products
  end
end
