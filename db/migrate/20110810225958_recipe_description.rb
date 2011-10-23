class RecipeDescription < ActiveRecord::Migration
  def self.up
	  change_table :recipes do |t|
	 		t.text :description
	 	end
  end

  def self.down
  end
end
