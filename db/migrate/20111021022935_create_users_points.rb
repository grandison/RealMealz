class CreateUsersPoints < ActiveRecord::Migration
  def self.up
	  create_table :users_points do |t|
	  	t.references  :users, :points
	  	t.datetime		:date_added  	
		end
  end

  def self.down
  	drop_table :users_points
  end
end
