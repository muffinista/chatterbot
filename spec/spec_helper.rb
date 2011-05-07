$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'chatterbot'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  
end

def fake_search(max_id = 100, result_count = 0)
  mock(TwitterOAuth::Client,
       {
         :search => {
           'max_id' => max_id,
           'results' => 1.upto(result_count).collect { |i| fake_tweet(i) }
         }        
       }
       )
end

def fake_replies(max_id = 100, result_count = 0)
  mock(TwitterOAuth::Client,
       {
         :replies => 1.upto(result_count).collect { |i| fake_tweet(i) }
       }
       )
end


def fake_tweet(index)
  {
    :index => index
  }
end
