class UpdateRecipes < ActiveRecord::Migration
  def self.up
    change_table :recipes do |t|
      t.string :source_link
      t.text :ingredient_list
      t.boolean :public, :default => true
    end    
  end

  def self.down
    change_table :recipes do |t|
      t.remove :public, :ingredient_list, :source_link
    end    
  end
end
