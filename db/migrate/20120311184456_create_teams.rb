class CreateTeams < ActiveRecord::Migration
  def up
    create_table :teams do |t|
      t.string :name
      t.integer :group_id
      t.timestamp :created_on
    end
    
    create_table :users_teams do |t|
      t.integer :user_id, :team_id
      t.timestamp :created_on
    end    
  end
  

  def down
    drop_table :teams
    drop_table :users_teams
  end
end
