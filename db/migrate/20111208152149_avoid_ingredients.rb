class AvoidIngredients < ActiveRecord::Migration
  def self.up
     change_table :users_ingredients do |t|
       t.boolean :avoid, :default => false
     end    
   end

   def self.down
     change_table :users_ingredients do |t|
       t.remove :avoid
     end    
   end
end
