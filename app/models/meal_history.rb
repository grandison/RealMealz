class MealHistory < ActiveRecord::Base
  belongs_to :kitchens
  belongs_to :meals
  belongs_to :recipe
end
