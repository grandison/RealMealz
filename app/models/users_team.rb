class UsersTeam < ActiveRecord::Base
  belongs_to :user
  belongs_to :team
  belongs_to :group
end