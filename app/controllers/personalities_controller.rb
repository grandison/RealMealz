class PersonalitiesController < ApplicationController
    active_scaffold :personalities do |config|
      config.columns = [:name, :picture]
    end
end
