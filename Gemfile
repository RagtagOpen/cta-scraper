source 'https://rubygems.org'

ruby File.read('.ruby-version').chomp

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', ' 5.1.2'

gem 'pg', '0.21.0'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'jquery-rails'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'

gem 'devise', '4.3.0'

gem 'nokogiri', '1.8.0'
gem 'httparty', '0.15.5'
gem 'cta_aggregator_client', '0.4.0'
gem 'Indirizzo', '0.1.7'
gem 'will_paginate', '3.1.6'

group :development, :test do
  gem 'dotenv-rails', '2.2.1'
  gem 'pry-rails', '0.3.6'
  gem 'pry-byebug', '3.4.2'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'rspec-rails', '3.5.2'
end
