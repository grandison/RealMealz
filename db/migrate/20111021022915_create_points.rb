class CreatePoints < ActiveRecord::Migration
  def self.up
	  create_table :points do |t|
	  	t.string  :name
	  	t.text		:description
			t.string 	:campaign
	  	t.integer :points
		end
  end

  def self.down
  	drop_table :points
  end
end
