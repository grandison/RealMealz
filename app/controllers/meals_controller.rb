class MealsController < ApplicationController
  active_scaffold :meals do |config|
    config.list.columns = [:scheduled_date, :kitchen, :meal_type, :recipes]
    config.columns = [:scheduled_date, :kitchen, :meal_type, :courses]
    config.columns[:courses].label = 'Courses'
  end
end
