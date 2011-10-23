class AppliancesController < ApplicationController
  
  active_scaffold :appliances do |config|
    config.list.columns = [:name, :kitchens]
    config.columns = [:name, :appliances_kitchens]
    config.columns[:appliances_kitchens].label = "Kitchens"
  end
end
