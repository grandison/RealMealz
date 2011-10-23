class CreateUsersIngredients < ActiveRecord::Migration
  def self.up
    create_table :users_ingredients do |t|
      t.integer :user_id
      t.integer :ingredient_id
      t.boolean :like
    end
  end

  def self.down
  end
end
