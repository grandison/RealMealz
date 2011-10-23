class RecipeInteger < ActiveRecord::Migration
   def self.up
	   change_table :recipes do |t|
	     t.remove :serving
	     t.remove :waittime
	     t.remove :worktime
	     t.string :serving
	     t.string :worktime
	     t.string :waittime

	   end
	 end
	
	 def self.down
	    change_table :recipes do |t|
	      
	   end
	   
	 end
end