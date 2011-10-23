class ChangeUsersRecipes < ActiveRecord::Migration
  def self.up
  	change_table :users_recipes do |t|
			t.boolean :in_recipe_box
		end
  end

  def self.down
  end
end
