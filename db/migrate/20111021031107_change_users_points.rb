class ChangeUsersPoints < ActiveRecord::Migration
  def self.up
  	change_table :users_points do |t|
  		t.rename :users_id, :user_id
  		t.rename :points_id, :point_id
  	end
  end

  def self.down
  end
end
