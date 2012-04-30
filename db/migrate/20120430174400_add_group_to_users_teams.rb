class AddGroupToUsersTeams < ActiveRecord::Migration
  def change
    change_table :users_teams do |t|
      t.integer :group_id
    end
  end
end
