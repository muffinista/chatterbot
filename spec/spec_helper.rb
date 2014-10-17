# -*- coding: utf-8 -*-
require 'simplecov'
SimpleCov.start

require 'bundler/setup'
Bundler.require

require "twitter"

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|

    # This option should be set when all dependencies are being loaded
    # before a spec run, as is the case in a typical spec helper. It will
    # cause any verifying double instantiation for a class that does not
    # exist to raise, protecting against incorrectly spelt names.
    mocks.verify_doubled_constant_names = true

  end
end

def test_bot
  bot = Chatterbot::Bot.new
  allow(bot).to receive(:load_config).and_return({})
  allow(bot).to receive(:update_config_at_exit)
  bot.reset!
  bot
end

def stubbable_client
  c = Twitter::Client.new
  allow(c).to receive_messages(:credentials? => true)
  c
end

def fake_search(max_id = 100, result_count = 0, id_base=0)
  result = 1.upto(result_count).each_with_index.map { |x, i|
    fake_tweet(max_id - i, id_base)
  }
  allow(result).to receive(:max_id).and_return(max_id)

  c = stubbable_client
  allow(c).to receive_messages(:search => result)
  c
end

def fake_replies(result_count = 0, id_base = 0)
  c = stubbable_client
  allow(c).to receive_messages(:mentions_timeline => 1.upto(result_count).collect { |i| fake_tweet(i, id_base)})
  c
end

def fake_home_timeline(result_count = 0, id_base = 0)
  c = stubbable_client
  allow(c).to receive_messages(:home_timeline => 1.upto(result_count).collect { |i| fake_tweet(i, id_base)})
  c
end

def fake_followers(count)
  c = stubbable_client
  allow(c).to receive_messages(:followers => 1.upto(count).collect { |i| fake_follower(i) })
  c
end

def fake_tweet(index, id=0)
  id = index if id <= 0
  x = {
    :from_user => "chatterbot",
    :index => index,
    :id => id,
    :text => "I am a tweet",
    :user => { :id => 1, :screen_name => "chatterbot" }
  }

  Twitter::Tweet.new(x)
end

def fake_follower(index=0)
  Twitter::User.new(:id => index, :name => "Follower #{index}",
                    :screen_name => "follower#{index}")
end

def fake_user(name, id = 1)
  Twitter::User.new(:id => id, :name => name, :screen_name => name)
end

