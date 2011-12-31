class AddRemoteUrlToRecipe < ActiveRecord::Migration
  def self.up
    change_table :recipes do |t|
      t.string :picture_remote_url
    end    
  end

  def self.down
    change_table :recipes do |t|
      t.remove :picture_remote_url
    end    
  end
end
