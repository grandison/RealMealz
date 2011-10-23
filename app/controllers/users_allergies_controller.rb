class UsersAllergiesController < ApplicationController
  active_scaffold :users_allergies do |config|
    config.columns[:level].form_ui = :select
    config.columns[:level].options = {:options => User.standard_positive_levels}
  end
end
