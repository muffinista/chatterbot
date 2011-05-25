#!/usr/bin/env ruby

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

#
# require the dsl lib to include all the methods you see below.
#
require 'chatterbot/dsl'

##
## If I wanted to exclude some terms from triggering this bot, I would list them here.
## For now, we'll block URLs to keep this from being a source of spam
##
exclude "http://"

blacklist "mean_user, private_user"

loop do
  replies do |tweet|

    # replace the incoming username with the handle of the user who tweeted us
    src = tweet[:text].gsub(/@echoes_bot/, tweet_user(tweet))

    # send it back!
    reply src, tweet
  end

  sleep 10
end
