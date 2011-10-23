class NewBalanceTable < ActiveRecord::Migration
  def self.up
    create_table :balance do |t|
      t.integer :veg
      t.integer :grain
      t.integer :protein
      t.text :description
    end
    change_table :users do |f|
    	f.integer :balance_id
    end
  end

  def self.down
    drop_table :balance
  end
end
