class MealHistory < ActiveRecord::Migration
  def up
    change_table :meals do |t|
      t.remove :eaten_on
    end
    
    create_table :meal_histories do |t|
      t.integer :kitchen_id, :recipe_id
      t.integer :balance_protein, :balance_vegetable, :balance_starch
      t.date :eaten_on
    end
  end

  def down
    drop_table :meal_histories
    
    change_table :meals do |t|
      t.date :eaten_on
    end
  end
end
