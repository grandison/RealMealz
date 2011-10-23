class Branch < ActiveRecord::Base
  has_many :branches_users
  has_many :users, :through => :branches_users
  has_many :branches_products
  has_many :products, :through => :branches_products
  belongs_to :store
end
