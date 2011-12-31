class PointsMaxTimes < ActiveRecord::Migration
  def self.up
    change_table :points do |t|
       t.integer :max_times, :default => 1
     end
  end

  def self.down
    change_table :points do |t|
       t.remove :max_times
     end
  end
end
