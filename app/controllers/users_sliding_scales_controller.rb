class UsersSlidingScalesController < ApplicationController
  active_scaffold :users_sliding_scales do |config|
    config.columns[:level].form_ui = :select
    config.columns[:level].options = {:options => User.standard_levels}
  end
end
