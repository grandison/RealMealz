class AddSeenCountToMeals < ActiveRecord::Migration
  def self.up
     change_table :meals do |t|
        t.integer :seen_count, :default => 0
      end
  end

  def self.down
    change_table :meals do |t|
       t.remove :seen_count
     end
  end
end
