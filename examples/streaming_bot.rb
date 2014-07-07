#!/usr/bin/env ruby

## This is a very simple working example of a bot using the streaming
## API. It's basically a copy of echoes_bot.rb, just using streaming.

#
# require the dsl lib to include all the methods you see below.
#
require 'rubygems'
require 'chatterbot/dsl'

consumer_secret 'foo'
secret 'bar'
token 'biz'
consumer_key 'bam'


puts "Loading echoes_bot.rb using the streaming API"

exclude "http://", "https://"

blacklist "mean_user, private_user"

streaming do
  favorited do |user, tweet|
    reply "@#{user.screen_name} thanks for the fave!", tweet
  end

  followed do |user|
    tweet "@#{user.screen_name} just followed me!"
    follow user
  end

  replies do |tweet|
    favorite tweet

    puts "It's a tweet!"
    src = tweet.text.gsub(/@echoes_bot/, "#USER#")  
    reply src, tweet
  end
end

