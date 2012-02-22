class InviteGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name, :sponsor
      t.date :start, :stop
    end
    
    create_table :invite_codes do |t|
      t.string :invite_code
      t.references :group
    end

    create_table :users_groups do |t|
      t.references :user, :group
      t.date :join_date
    end
  end

end
