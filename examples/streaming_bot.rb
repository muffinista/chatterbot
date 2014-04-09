#!/usr/bin/env ruby

## This is a very simple working example of a bot using the streaming
## API. It's basically a copy of echoes_bot.rb, just using streaming.

#
# require the dsl lib to include all the methods you see below.
#
require 'rubygems'
require 'chatterbot/dsl'

puts "Loading echoes_bot.rb using the streaming API"

exclude "http://", "https://"

blacklist "mean_user, private_user"

streaming_tweets do |tweet|
  puts "It's a tweet!"
  src = tweet.text.gsub(/@echoes_bot/, "#USER#")  
  reply src, tweet
end

