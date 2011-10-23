class Roles < ActiveRecord::Migration
  def self.up
    change_table :members do |t|
      t.string :role
    end
    
  end
  
  def self.down
    change_table :members do |t|
      t.remove :role
    end
  end
end