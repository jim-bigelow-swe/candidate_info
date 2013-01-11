source 'https://rubygems.org'

gem 'rails', '3.2.11'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# for Heroku deployment - as described in Ap. A of ELLS book
group :development, :test do
  gem 'sqlite3'
  gem 'ruby-debug19', :require => 'ruby-debug'
  gem 'cucumber-rails'
  gem 'cucumber-rails-training-wheels'
  gem 'database_cleaner'
  gem 'railroady'
  #gem 'metric_fu'
  gem 'capybara'
  gem 'launchy'
  gem 'factory_girl'
  gem 'factory_girl_rails'
  gem 'webrat'
  gem 'rspec-rails'
  gem 'simplecov'
  gem 'shoulda-matchers'
  gem 'schema_to_scaffold'
  gem 'foreigner'
  gem 'immigrant'
end
group :production do
  gem 'pg'
end

group :test do
  gem 'faker'
  gem 'guard-rspec'
end

gem "levenshtein-ffi", :require => 'levenshtein'

gem 'haml'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
#gem 'debugger'
