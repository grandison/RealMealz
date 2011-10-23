class CreateUsersRecipes < ActiveRecord::Migration
  def self.up
    create_table :users_recipes do |t|
      t.references :user, :recipe
      t.string :source
      t.integer :rating
      t.datetime :date_added
      t.boolean :active
    end
  end

  def self.down
    drop_table :users_recipes
  end
end
