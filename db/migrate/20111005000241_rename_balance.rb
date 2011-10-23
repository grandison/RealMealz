class RenameBalance < ActiveRecord::Migration
  def self.up
    rename_table :balance, :balances
  end
  

  def self.down
    rename_table :balances, :balance
  end
end
