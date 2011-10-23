class ChangeRecipesTimesToint < ActiveRecord::Migration
  def self.up
  	change_table :recipes do |t|
			t.change :preptime, :integer
			t.change :cooktime, :integer
			t.change :servings, :integer
			t.change :approved, :boolean
		end
  end

  def self.down
  end
end
