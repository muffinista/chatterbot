source 'https://rubygems.org'

gemspec

#gem "twitter_oauth"
#gem "sequel"

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development do
  gem 'simplecov', :require => false, :group => :test

  gem "shoulda", ">= 0"
  gem "rspec"

  gem "watchr"
end

#
# couple extra gems for testing db connectivity
#
group :test do
  gem "sequel"
  gem "mysql"
  gem "sqlite3"
end
