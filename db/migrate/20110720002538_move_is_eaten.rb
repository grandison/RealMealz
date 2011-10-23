class MoveIsEaten < ActiveRecord::Migration
  def self.up
    change_table :meals_recipes do |t|
      t.boolean :is_eaten
    end
    change_table :meals do |t|
      t.remove :is_eaten
    end
  end
  
  def self.down
    change_table :meals do |t|
      t.boolean :is_eaten
    end
    change_table :meals_recipes do |t|
      t.remove :is_eaten
    end
  end
end
