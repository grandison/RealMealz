class RecipePicture < ActiveRecord::Migration
  def self.up
    change_table :recipes do |t|
      t.remove :picture
      t.string :picture_file_name, :picture_content_type
      t.integer :picture_file_size
      t.datetime :picture_updated_at      
    end
  end

  def self.down
    change_table :recipes do |t|
      t.remove :picture_file_name, :picture_content_type, :picture_file_size, :picture_updated_at
      t.binary :picture 
    end
  end
end
