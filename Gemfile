source 'http://rubygems.org'

# RealMealz is currently using Rails version 3.0.9
gem 'rails', '3.0.9'
gem 'rake'

# If you use a different adapter, change it here but don't check it in. Default: gem 'mysql2', '~> 0.2.7'
#gem 'sqlite3'
#gem 'mysql'
#gem 'mysql2', '~> 0.2.7'
gem 'mysql2'
gem 'pg'

# ruby_units needs to be loaded first because it adds a String.from method that conflicts with the Rails String.from
# method that active_scaffold uses. Otherwise, it will produce errors like "'as_categories' Unit not recognized"
gem "ruby-units", "= 1.3.2"

# Other units for RealMealz
gem "mongrel", '>= 1.2.0.pre2'
gem "authlogic"
gem 'dynamic_form'
gem "paperclip", "~> 2.4"
gem 'fog'
gem "simple_autocomplete"
gem "rails3-jquery-autocomplete", "~> 0.9.0"
gem 'will_paginate'
gem 'rest-open-uri'
gem 'haml'
gem 'cells'
gem 'nokogiri'
gem 'admin_data', '= 1.1.14'

#---- For Heroku ----
gem 'thin'
gem 'newrelic_rpm'

#--- For debugging  -----
# gem "ruby-debug"
gem "yaml_db"

#--- experimental ---
# gem 'rhoconnect-rb'

#----- Below here are units from the original Gemfile ------
# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19', :require => 'ruby-debug'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  # gem 'factory_girl_rails'
  # gem 'machinist', '>= 2.0.0.beta2'
end
