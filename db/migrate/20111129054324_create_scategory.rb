class CreateScategory < ActiveRecord::Migration
  def self.up
    create_table :scategory do |t|
	  	t.string :name	      
    end
    change_table :skills do |t|
		  t.remove :equipment
		  t.integer :scategory_id
  	end
  end

  def self.down
	  drop_table :scategory
	  change_table :skills do |t|
			t.remove :scategory_id
  	end
  end
end
