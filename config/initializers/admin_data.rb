AdminData.config do |config|
  #Disable their security because we do our own
  config.is_allowed_to_view = lambda {|controller| true }
  config.is_allowed_to_update = lambda {|controller| true }
end