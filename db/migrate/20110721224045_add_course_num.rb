class AddCourseNum < ActiveRecord::Migration
  def self.up
    change_table(:meals_recipes) do |t|
      t.integer :course_num, :default => 1
    end
  end

  def self.down
    change_table(:meals_recipes) do |t|
      t.remove :course_num
    end
  end
end
