class AddRecipeBalance < ActiveRecord::Migration
  def self.up
  	change_table :recipes do |t|
  	  t.datetime :updated_at
  	  t.datetime :balance_updated_at
  	  t.integer :balance_protein
  	  t.integer :balance_vegetable
  	  t.integer :balance_starch
  	end
  end

  def self.down
  	change_table :recipes do |t|
  	  t.remove :updated_at, :balance_updated_at, :balance_protein, :balance_vegetable, :balance_starch
  	end
  end
end
