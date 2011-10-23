class UsersCategoriesController < ApplicationController
  active_scaffold :users_categories do |config|
     config.columns[:level].label = 'Percent'
     config.columns[:level].form_ui = :select
     config.columns[:level].options = {:options => [nil] + (0..10).map {|n| "#{n*10}"}.reverse}
  end
end
