class BranchesProductsController < ApplicationController
  active_scaffold :branches_products do |config|
#    config.list.columns = [:name, :categories]
#    config.columns = [:name, :categories_ingredients]
#    config.columns[:categories_ingredients].label = "Categories"
  end
end
