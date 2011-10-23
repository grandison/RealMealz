class RecipesPersonality < ActiveRecord::Base
  belongs_to :recipe
  belongs_to :personality
end
