class IngredientDescription < ActiveRecord::Migration
  def self.up
    change_table :ingredients do |t|
      t.string :description
    end
  end

  def self.down
     change_table :ingredients do |t|
       t.remove :description 
    end
    
  end
end
