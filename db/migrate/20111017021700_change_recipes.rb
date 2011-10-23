class ChangeRecipes < ActiveRecord::Migration
  def self.up
	  change_table :recipes do |t|
	  		t.rename :worktime, :preptime 
	  		t.rename :waittime, :cooktime
	  		t.rename :description, :intro
	  		t.rename :instructions, :cooksteps
	  		t.text :prepsteps
	  		t.string :skills
	  		t.rename :serving, :servings
  	end
  end

  def self.down
  end
end
