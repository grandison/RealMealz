class RecipeWorktimeWaittime < ActiveRecord::Migration

  def self.up
    change_table :recipes do |t|
      t.integer :worktime
      t.integer :waittime
      t.integer :serving
      t.text :original
      t.text :source
      t.string :tags
    end
  end

  def self.down
     change_table :recipes do |t|
      t.remove :worktime
			t.remove :waittime
			t.remove :serving
      t.remove :original
      t.remove :source
      t.remove :tags
     end    
  end
end
 
