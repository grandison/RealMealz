class Group < ActiveRecord::Base
  has_many :invite_codes
  has_many :users_groups
  has_many :users, :through => :users_groups
  has_many :users_teams
  # MD Apr-2012. Slight conflict here. Groups has teams directly and also through users_teams. But the group in users_teams is
  # just used for convenience to see what group that team belongs to when checking for duplicates. So just include
  # the main team relation here
  has_many :teams   
end
