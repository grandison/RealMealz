class CreateSlidingScales < ActiveRecord::Migration
  def self.up
    create_table :sliding_scales do |t|
      t.string :name1, :name2
    end
  end

  def self.down
    drop_table :sliding_scales
  end
end
