class RenameScategoryTable < ActiveRecord::Migration
  def self.up
    rename_table :scategory, :scategories
  end

  def self.down
    rename_table :scategories, :scategory
  end
end
