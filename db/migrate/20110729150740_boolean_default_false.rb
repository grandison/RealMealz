class BooleanDefaultFalse < ActiveRecord::Migration
  def self.up
    change_column :courses, :is_eaten, :boolean, :default => false
    change_column :users_recipes, :active, :boolean, :default => false
    change_table :users do |t|
      t.remove :is_admin
    end
  end

  def self.down
    change_table :users do |t|
      t.boolean :is_admin
    end
  end
end
