source 'http://rubygems.org'

gem 'rails', '3.1.3'

group :mysql do
  gem 'mysql2'
end

# ruby_units needs to be loaded first because it adds a String.from method that conflicts with the Rails String.from
# method that active_scaffold uses. Otherwise, it will produce errors like "'as_categories' Unit not recognized"
gem "ruby-units", "= 1.3.2"

# Other units for RealMealz
gem "authlogic"
gem 'dynamic_form'
gem "cocaine", "= 0.3.2" # MD Oct-2012 This is needed for paperclip 3.2.0 to avoid the "identify" bug
gem "paperclip"
gem 'fog'
gem "simple_autocomplete"
gem "rails3-jquery-autocomplete"
gem 'will_paginate'
gem 'haml'
gem 'cells'
gem 'nokogiri'
gem 'admin_data'
gem 'jquery-rails'
gem "yaml_db"
gem "dalli"
gem "airbrake"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.5'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

group :test do
  # Pretty printed test output
  #gem 'turn', '~> 0.8.3', :require => false
  gem 'sqlite3' # Heroku bombs on this and BUNDLE_WITHOUT doesnt work so put it here under test
end

# For local development
group :development do
  gem "thin", :platforms => :ruby
end

# For Heroku
group :heroku do
  gem 'pg'
  gem 'unicorn'
end

# For some reason, putting this in the Heroku group doesn't load
gem 'newrelic_rpm'

# For BlueBox
group :bluebox do
  gem 'mysql'
end

