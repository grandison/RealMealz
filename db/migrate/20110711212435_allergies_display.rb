class AllergiesDisplay < ActiveRecord::Migration
  def self.up
  	change_table :allergies do |t|
     t.string :display
    end
  end

  def self.down
   change_table :allergies do |t|
	   t.remove :display
   end
  end
end
