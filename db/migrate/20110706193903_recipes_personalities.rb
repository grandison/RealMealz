class RecipesPersonalities < ActiveRecord::Migration
  def self.up
    create_table :recipes_personalities do |t|
      t.integer :level
      t.references :recipe
      t.references :personality
    end
    end

  def self.down
     drop_table :recipes_personalities
  end
end
