class Appliance < ActiveRecord::Base
  has_many :appliances_kitchens
  has_many :kitchens, :through => :appliances_kitchens
end
