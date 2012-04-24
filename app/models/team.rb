class Team < ActiveRecord::Base
  belongs_to :group
  has_many :users_teams
  has_many :users, :through => :users_teams
  
  def points
    self.users.reduce(0) {|sum, user| sum + user.get_points} 
  end
end