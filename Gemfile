source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.1'

# Env loading in development
gem 'dotenv-rails', groups: [:development, :staging, :production]

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Sass port of Bootstrap
gem 'bootstrap-sass'

# Bootstrap forms
gem 'bootstrap_form'

# Font Awesome in Sass
gem 'font-awesome-sass'

# Markdown
gem 'redcarpet'
gem 'rouge'
gem 'rails-bootstrap-markdown'

gem 'ace-rails-ap'

# Pagination of long lists
gem 'kaminari'
gem 'bootstrap-kaminari-views'

# Use Settingslogic for config variables
gem 'settingslogic'

# Use ActiveModel has_secure_password
gem 'bcrypt-ruby', '3.0.0', :require => 'bcrypt'

# Use Puma as the app server
gem 'puma', '~> 3.0'

# Use delayed_job for handling sending mails
gem 'delayed_job_active_record'

# Rails variables in Javascript code
gem 'gon'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test do
  # RSpec for testing
  gem 'rspec-rails'

  # Fixtures replacement
  gem 'factory_girl_rails'

  # Feature specs
  gem 'capybara'

  # Additional convenient RSpec matchers
  gem 'shoulda-matchers', require: false

  # Cleaning the database between specs
  gem 'database_cleaner'

  # Stubbing of external services
  gem 'webmock'

  # For JS tests
  gem 'poltergeist'
end

# User authentication
gem 'devise'

# Postgres database
gem 'pg'

# MySql database
# gem 'mysql2', '~> 0.3.18'

# Google OAuth 2 authorization
gem 'omniauth-google-oauth2'

# GitHub authorization
gem 'omniauth-github'

# Facebook authorization
gem 'omniauth-facebook'

gem "foreman", "~> 0.63.0"

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  gem "win32console", platforms: [:mingw, :mswin, :x64_mingw]

  gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw]
end


