class DeleteCourses < ActiveRecord::Migration
  class Course < ActiveRecord::Base
  end
  class Meal < ActiveRecord::Base
  end
     
  def self.up
   change_table :meals do |t|
      t.integer :recipe_id
      t.float :servings
      t.boolean :is_eaten, :default => false
    end
    
    Meal.reset_column_information
    
    Course.all.each do |course|
      Meal.find(course.meal_id).update_attributes(:recipe_id => course.recipe_id) rescue nil
    end
    Meal.delete_all(:recipe_id => nil)

    drop_table :courses
  end

  def self.down
    create_table "courses", :force => true do |t|
      t.float   "servings"
      t.integer "meal_id"
      t.integer "recipe_id"
      t.boolean "is_eaten",  :default => false
      t.integer "order_num", :default => 1
    end

    change_table :meals do |t|
      t.remove :recipe_id, :servings, :is_eaten
    end
  end
end
