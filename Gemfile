gem "sinatra"
gem "activerecord"
gem "sinatra-activerecord"
gem 'newrelic_rpm'

group :production,:development do
  gem "pg"
  gem 'thin'
end
group :test do
  gem 'sqlite3'
  gem 'rspec'
  gem 'rack-test'
end
