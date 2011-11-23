#!/usr/bin/env ruby


#
# require the dsl lib to include all the methods you see below.
#
require 'rubygems'
require 'chatterbot/dsl'

puts "Loading echoes_bot.rb"

##
## If I wanted to exclude some terms from triggering this bot, I would list them here.
## For now, we'll block URLs to keep this from being a source of spam
##
exclude "http://"

blacklist "mean_user, private_user"

puts "checking for replies to me"
replies do |tweet|
  
  # replace the incoming username with the handle of the user who tweeted us
  # src = tweet[:text].gsub(/@echoes_bot/, tweet_user(tweet))

  # replace the incoming username with #USER#, which will be replaced
  # with the handle of the user who tweeted us by the
  # replace_variables helper
  src = tweet[:text].gsub(/@echoes_bot/, "#USER#")  

  # send it back!
  reply src, tweet
end
