class UsersPersonalitiesController < ApplicationController
    active_scaffold :users_personalities do |config|
    config.columns[:level].form_ui = :select
    config.columns[:level].options = {:options => User.standard_levels}
    end
end
