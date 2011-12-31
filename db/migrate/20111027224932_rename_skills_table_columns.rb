class RenameSkillsTableColumns < ActiveRecord::Migration
  def self.up
  	change_table :skills do |t|
  		t.rename :names, :name
  	end
  end

  def self.down
  	change_table :skills do |t|
  		t.rename :name, :names
  	end
  end
end
