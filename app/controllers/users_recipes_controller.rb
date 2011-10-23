class UsersRecipesController < ApplicationController
  active_scaffold :users_recipes do |config|
    config.columns[:rating].form_ui = :select
    config.columns[:rating].options = {:options => User.standard_positive_levels}
  end
end
