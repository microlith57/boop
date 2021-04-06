# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1'
# Use postgreSQL as the database for Active Record
gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 3.12'
# Use SCSS for stylesheets, using LibSass
gem 'sassc-rails', '~> 2.1', '>= 2.1.1'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 5.0'
# Turbolinks makes navigating your web application faster.
# Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and
  # get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console'
  # anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  gem 'webdrivers'
  # gem 'database_cleaner'
end

group :test, :development do
  # Adds better testing framework
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'timecop'
  # gem 'vcr'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Administrator models
gem 'devise'

# Pagination
gem 'pagy'

# Decent UI framework
gem 'autoprefixer-rails'
gem 'foundation-rails'

# Solargraph language server
gem 'solargraph', group: :development

# Rubocop
group :development do
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
end

# Reek
group :development do
  gem 'reek'
end

# Fast HAML implementation for views
gem 'hamlit-rails'
group :development do
  gem 'haml_lint', require: false
  gem 'html2haml'
end

# Environment variable file for local development & testing
gem 'dotenv-rails'

# Webpacker to pack JS files
gem 'webpacker', '~> 5.x'

# Human-readable local time
gem 'local_time'

# Barcode to PNG
gem 'barby'
gem 'chunky_png'

# Detect N+1 queries
gem 'bullet', group: 'development'

# Sortable tables
gem 'ransack', github: 'activerecord-hackery/ransack'

# Config YML file
gem 'figaro'
