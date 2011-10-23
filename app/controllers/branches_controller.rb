class BranchesController < ApplicationController
  active_scaffold :branches do |config|
    config.list.columns = [:name, :street, :city, :state, :zip, :website, :email, :phone, :store]
    config.columns = [:name, :street, :city, :state, :zip, :website, :email, :phone, :store, :branches_users, :branches_products]
    config.columns[:store].form_ui = :select
    config.columns[:branches_users].label = "Users"
    config.columns[:branches_products].label = "Products"
  end
end
