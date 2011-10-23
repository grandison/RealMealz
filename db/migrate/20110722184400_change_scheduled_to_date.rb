class ChangeScheduledToDate < ActiveRecord::Migration
  def self.up
    change_table(:meals) do |t|
      t.remove :scheduled_date
      t.date :scheduled_date
    end
  end
  
  def self.down
    change_table(:meals) do |t|
      t.remove :scheduled_date
      t.datetime :scheduled_date
    end
  end
end
