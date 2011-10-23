class MembersToUsers < ActiveRecord::Migration
  def self.up
    rename_table :branches_members, :branches_users
    rename_table :members, :users
    rename_table :members_allergies, :users_allergies
    rename_table :members_personalities, :users_personalities
    rename_table :members_sliding_scales, :users_sliding_scales
    
    rename_column :branches_users, :member_id, :user_id
    rename_column :users_allergies, :member_id, :user_id
    rename_column :users_personalities, :member_id, :user_id
    rename_column :users_sliding_scales, :member_id, :user_id
  end
  
  def self.down
    rename_column :branches_users, :user_id, :member_id
    rename_column :users_allergies, :user_id, :member_id
    rename_column :users_personalities, :user_id, :member_id
    rename_column :users_sliding_scales, :user_id, :member_id
    
    rename_table :branches_users, :branches_members 
    rename_table :users, :members
    rename_table :users_allergies, :members_allergies
    rename_table :users_personalities, :members_personalities
    rename_table :users_sliding_scales, :members_sliding_scales
  end
end
