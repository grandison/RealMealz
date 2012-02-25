class AddInviteCodeToUsersGroups < ActiveRecord::Migration
  def up
    change_table :users_groups do |t|
      t.integer :invite_code_id
    end
  end
    
  def down
    change_table :users_groups do |t|
      t.remove :invite_code_id
    end
  end  
end
