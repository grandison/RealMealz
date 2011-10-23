class UsersCategories < ActiveRecord::Migration
 def self.up
    create_table :users_categories do |t|
      t.integer :level
      t.references :user
      t.references :category
    end
    end

  def self.down
     drop_table :users_categories
  end
end
