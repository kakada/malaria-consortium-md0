if RUBY_VERSION =~ /1.9/
    Encoding.default_external = Encoding::UTF_8
    Encoding.default_internal = Encoding::UTF_8
end
source 'http://rubygems.org'

gem 'rails', '3.0.6'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql2', "=0.2.7"
gem 'rake', '0.8.7'


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

#from rails2
# gem "fastercsv" #change :lib to :require


# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end

gem "capistrano"
gem "rvm-capistrano"

gem 'will_paginate', :git => 'git://github.com/mislav/will_paginate.git', :branch => 'rails3'
gem 'jquery-rails'
gem 'nuntium_api', '>=0.11', :require => 'nuntium'
gem 'devise'


#gem "rmagick"
#gem 'foreigner'

group :development, :test do
  gem 'newrelic_rpm'
  gem "autotest"
  gem "webrat"
  gem "rspec-rails"
  gem "factory_girl_rails"
  gem "machinist", "1.0.6"
  gem "faker"
  gem 'debugbar'
  gem "simplecov"
  gem 'ruby-debug19', :require => 'ruby-debug'
  #gem "query_reviewer", :git => "git://github.com/nesquena/query_reviewer.git"
end
