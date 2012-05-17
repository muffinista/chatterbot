# -*- coding: utf-8 -*-
require 'simplecov'
SimpleCov.start
#$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
#$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'bundler/setup'
Bundler.require

#require "twitter_oauth"
require "twitter"

require 'tempfile'
require 'sqlite3'


# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}


def test_bot
  bot = Chatterbot::Bot.new
  bot.stub!(:load_config).and_return({})
  bot
end

def fake_search(max_id = 100, result_count = 0, id_base=0)
  mock(Twitter::Client,
       {
         :credentials? => true,
         :search => 1.upto(result_count).collect { |i| fake_tweet(i, id_base) }
       }
       )
end

def fake_replies(max_id = 100, result_count = 0, id_base = 0)
  mock(Twitter::Client,
       {
         :credentials? => true,
         :mentions => 1.upto(result_count).collect { |i| fake_tweet(i, id_base) }
       }
       )
end

def fake_tweet(index, id=0)
  id = index if id <= 0

  Twitter::Status.new(
                      'from_user' => "chatterbot",
                      'index' => index,
                      'id' => id,
                      'user' => {
                        'screen_name' => "chatterbot"
                      })
end
