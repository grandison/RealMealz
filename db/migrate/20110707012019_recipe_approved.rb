class RecipeApproved < ActiveRecord::Migration
  def self.up
		change_table :recipes do |t|
      t.string :approved
     end
     
  end

  def self.down
  	change_table :recipes do |t|
      t.remove :approved
     end
  end
end
