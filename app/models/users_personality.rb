class UsersPersonality < ActiveRecord::Base
  belongs_to :user
  belongs_to :personality
end
