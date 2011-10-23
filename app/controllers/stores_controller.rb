class StoresController < ApplicationController
  active_scaffold :stores do |config|
    config.list.columns = [:name, :street, :city, :state, :zip, :website, :email, :phone, :branches]
    config.columns = [:name, :street, :city, :state, :zip, :website, :email, :phone]
  end
  
 
end
