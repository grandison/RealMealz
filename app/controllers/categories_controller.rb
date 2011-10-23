class CategoriesController < ApplicationController
  active_scaffold :categories do |config|
    config.columns = [:name, :ingredients]
  end
end
