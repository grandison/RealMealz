class AddKitchenToRecipe < ActiveRecord::Migration
  def self.up
    change_table :recipes do |t|
      t.integer :kitchen_id
    end    
  end

  def self.down
    change_table :recipes do |t|
      t.remove :kitchen_id
    end    
  end
end
