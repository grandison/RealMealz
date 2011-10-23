class SlidingScale < ActiveRecord::Base
  has_many :users_sliding_scales
  has_many :users, :through => :users_sliding_scales

  def name
    "#{name1}/#{name2}"
  end

end
