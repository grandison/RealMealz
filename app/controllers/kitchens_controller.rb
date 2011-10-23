class KitchensController < ApplicationController
  active_scaffold :kitchens do |config|
    config.list.columns = [:name, :users, :meals, :appliances]
    config.columns = [:name, :meals, :appliances_kitchens]
    config.columns[:appliances_kitchens].label = "Appliances"
  end
end
