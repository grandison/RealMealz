class CreateAllergies < ActiveRecord::Migration
  def self.up
    create_table :allergies do |t|
      t.string :name
      t.integer :parent_id
    end
  end

  def self.down
    drop_table :allergies
  end
end
