source 'https://rubygems.org'
ruby '2.2.1'
gem 'rails', '~> 4.2'
gem 'sass-rails'
gem 'uglifier'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder'
gem 'bootstrap-sass'
gem 'devise'
gem 'figaro'
gem 'haml-rails'
gem 'simple_form'
gem 'thin'
gem 'google-api-client', '0.9.pre3'
gem 'googleauth'

group :production do # Postgres for heroku
  gem 'pg'
  gem 'rails_12factor'
  # Use Unicorn as the app server
  gem 'unicorn'
end

group :development do
  gem 'sqlite3'
  gem 'better_errors'
  gem 'binding_of_caller', :platforms=>[:mri_19, :mri_20, :rbx]
  gem 'html2haml'
  gem 'quiet_assets'
  gem 'rails_layout'
end