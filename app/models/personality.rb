class Personality < ActiveRecord::Base
    has_many :users_personalities
    has_many :users, :through => :users_personalities
    has_many :recipes_personalities
    has_many :recipes, :through => :recipes_personalities
end
