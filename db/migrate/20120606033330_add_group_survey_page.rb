class AddGroupSurveyPage < ActiveRecord::Migration
  def self.up
    change_table :groups do |t|
      t.string :survey_page
    end
  end
  def self.down
    change_table :groups do |t|
      t.remove :survey_page
    end    
  end
  
end
