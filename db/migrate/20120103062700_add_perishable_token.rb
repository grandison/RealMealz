class AddPerishableToken < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string :perishable_token, :default => ''
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :perishable_token
    end
  end
end
