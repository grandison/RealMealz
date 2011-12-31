class UpdateSkillsTable < ActiveRecord::Migration
  def self.up
 		change_table :skills do |t|
	      t.string :equipment 
    end
  end

  def self.down
 		change_table :skills do |t|
	      t.remove :equipment 
    end
  end
end
