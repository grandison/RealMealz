source 'http://rubygems.org'

gem 'rails', '3.1.3'

# If you use a different adapter, change it here but don't check it in. Default: gem 'mysql2', '~> 0.2.7'
#gem 'sqlite3'
#gem 'mysql'
#gem 'mysql2', '~> 0.2.7'
gem 'mysql2'

# ruby_units needs to be loaded first because it adds a String.from method that conflicts with the Rails String.from
# method that active_scaffold uses. Otherwise, it will produce errors like "'as_categories' Unit not recognized"
gem "ruby-units", "= 1.3.2"

# Other units for RealMealz
gem "authlogic"
gem 'dynamic_form'
gem "paperclip"
gem 'fog'
gem "simple_autocomplete"
gem "rails3-jquery-autocomplete"
gem 'will_paginate'
gem 'rest-open-uri'
gem 'haml'
gem 'cells'
gem 'nokogiri'
gem 'admin_data'
gem 'jquery-rails'
gem "yaml_db"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.5'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

group :test do
  # Pretty printed test output
  gem 'turn', '~> 0.8.3', :require => false
end

# If not using Heroku
group :development do
  gem "thin"
end

# For Heroku
group :production do
  gem 'pg'
  gem 'unicorn'
  gem 'newrelic_rpm'
end



