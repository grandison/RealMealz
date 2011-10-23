class AppliancesKitchen < ActiveRecord::Base
  belongs_to :appliance
  belongs_to :kitchen
end
