class Category < ActiveRecord::Base
  has_many :categories_ingredients
  has_many :ingredients, :through => :categories_ingredients
  has_many :users_categories
  has_many :users, :through => :users_categories
end
