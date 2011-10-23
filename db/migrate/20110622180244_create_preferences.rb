class CreatePreferences < ActiveRecord::Migration
  def self.up
    create_table :personalities do |t|
      t.string :name
      t.binary :picture
    end
    
    create_table :members_personalities do |t|
      t.integer :level
      t.references :member
      t.references :personality
    end

    create_table :members_allergies do |t|
      t.integer :level
      t.references :member
      t.references :allergy 
    end

    create_table :members_sliding_scales do |t|
      t.integer :level
      t.references :member
      t.references :sliding_scale
    end

    drop_table :members_preferences
  end

  def self.down
    create_table :members_preferences do |t|
      t.integer :level
      t.references :member
      t.references :preference, :polymorphic => {:default => 'SlidingScale'}
    end

    drop_table :members_sliding_scales
    drop_table :members_allergies    
    drop_table :members_personalities
    drop_table :personalities
  end
end
