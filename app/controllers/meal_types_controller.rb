class MealTypesController < ApplicationController
  active_scaffold :meal_types do |config|
    config.columns = [:name]
  end
end
