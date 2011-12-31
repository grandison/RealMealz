class CreateSkillsTable < ActiveRecord::Migration
  def self.up
   create_table :skills do |t|
	  		t.string :names 
	  		t.text :description
	  		t.string :video_link
	  		t.integer :level
  	end    
	end

  def self.down
    drop_table :skills
  end
end
