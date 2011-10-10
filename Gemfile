source :rubygems
gemspec

#gem "twitter_oauth"
#gem "sequel"

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development do
  gem 'simplecov', :require => false, :group => :test

  gem "shoulda", ">= 0"
  gem "rspec"

  gem "bundler", "~> 1.0.0"
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
