# -*- coding: utf-8 -*-
require 'simplecov'
SimpleCov.start
#$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
#$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'bundler/setup'
Bundler.require

#require "twitter_oauth"
require "twitter"

#require 'tempfile'
#require 'sqlite3'


# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}


def test_bot
  bot = Chatterbot::Bot.new
  bot.stub(:load_config).and_return({})
  bot.stub(:update_config_at_exit)
  bot.reset!
  bot
end

def fake_search(max_id = 100, result_count = 0, id_base=0)
  result = 1.upto(result_count).each_with_index.map { |x, i|
    fake_tweet(max_id - i, id_base)
  }
  result.stub(:max_id).and_return(max_id)

  double(Twitter::Client,
       :credentials? => true,
       :search => result
       )
end

def fake_replies(result_count = 0, id_base = 0)
  double(Twitter::Client,
       {
         :credentials? => true,
         :mentions_timeline => 1.upto(result_count).collect { |i| fake_tweet(i, id_base) }
       }
       )
end

def fake_followers(count)
  double(Twitter::Client,
       {
         :credentials? => true,
         :followers => 1.upto(count).collect { |i| fake_follower(i) }
       }
       )
end

def fake_tweet(index, id=0)
  id = index if id <= 0
  x = {
    :from_user => "chatterbot",
    :index => index,
    :id => id,
    :user => { :id => 1, :screen_name => "chatterbot" }
  }

  #as_object == true ? Twitter::Tweet.new(x) : x
  Twitter::Tweet.new(x)
end

def fake_follower(index=0)
  Twitter::User.new(:id => index, :name => "Follower #{index}",
                    :screen_name => "follower#{index}")
end

def fake_user(name)
  Twitter::User.new(:id => 1, :name => name, :screen_name => name)
end

