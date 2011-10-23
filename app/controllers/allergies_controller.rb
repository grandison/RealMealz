class AllergiesController < ApplicationController
  
  active_scaffold :allergies do |config|
    config.columns = [:name, :parent, :specifics]
  end
end
