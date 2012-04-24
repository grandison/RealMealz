class Group < ActiveRecord::Base
  has_many :invite_codes
  has_many :users_groups
  has_many :users,:through => :users_groups
  has_many :teams
end
