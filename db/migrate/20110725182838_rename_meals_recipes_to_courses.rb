class RenameMealsRecipesToCourses < ActiveRecord::Migration
  def self.up
    rename_table :meals_recipes, :courses
    change_table :courses do |t|
      t.rename :course_num, :order
    end
  end

  def self.down
    change_table :courses do |t|
      t.rename :order, :course_num
    end
    rename_table :courses, :meals_recipes
  end
end
