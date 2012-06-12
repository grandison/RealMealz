class CreateSurvey < ActiveRecord::Migration
  def self.up
	  create_table :surveys do |t|
	  	t.integer :user_id
	  	t.datetime :date_added  
	  	t.string  :question
	  	t.string	:answer
		end
  end

  def self.down
  	drop_table :surveys
  end
end
