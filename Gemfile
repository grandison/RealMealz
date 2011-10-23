source 'http://rubygems.org'

# RealMealz is currently using Rails version 3.0.9
gem 'rails', '3.0.9'

# If you use a different adapter, change it here but don't check it in. Default: gem 'mysql2', '~> 0.2.7'
#gem 'sqlite3'
#gem 'mysql'
gem 'mysql2', '~> 0.2.7'

# ruby_units needs to be loaded first because it adds a String.from method that conflicts with the Rails String.from
# method that active_scaffold uses. Otherwise, it will produce errors like "'as_categories' Unit not recognized"
gem "ruby-units"

# Other units for RealMealz
gem "mongrel"
gem 'active_scaffold', :git => 'git://github.com/activescaffold/active_scaffold.git', :branch => 'rails-3.0'
#gem "active_scaffold-vho"
gem "authlogic"
gem "paperclip", "~> 2.3"
gem "rails3-jquery-autocomplete", "~> 0.9.0"
gem 'will_paginate', '3.0.pre2'
gem 'dynamic_form'

#--- For debugging, include this
gem "ruby-debug"

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
# group :development, :test do
#   gem 'webrat'
# end
