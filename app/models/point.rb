class Point < ActiveRecord::Base
  has_many :users_points
  has_many :users, :through => :users_points 
end


