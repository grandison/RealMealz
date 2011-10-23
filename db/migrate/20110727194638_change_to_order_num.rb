class ChangeToOrderNum < ActiveRecord::Migration
  def self.up
    change_table :courses do |t|
      t.rename :order, :order_num
    end
  end

  def self.down
    change_table :courses do |t|
      t.rename :order_num, :order
    end
  end
end
