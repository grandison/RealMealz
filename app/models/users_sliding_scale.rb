class UsersSlidingScale < ActiveRecord::Base
  belongs_to :user
  belongs_to :sliding_scale
end
