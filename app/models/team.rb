class Team < ActiveRecord::Base
  belongs_to :group
  has_many :users_teams
  has_many :users, :through => :users_teams
end