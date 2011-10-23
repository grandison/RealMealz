class ChangeMealsToScheduledDate < ActiveRecord::Migration
  def self.up
    change_table(:meals) do |t|
      t.rename :scheduled_time, :scheduled_date      
    end
  end

  def self.down
    change_table(:meals) do |t|
       t.rename :scheduled_date, :scheduled_time      
    end
  end
end
