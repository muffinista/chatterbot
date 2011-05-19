#!/usr/bin/env ruby

require '../lib/chatterbot'
require '../lib/chatterbot/dsl'

##
## If I wanted to exclude some terms from triggering this bot, I would list them here.
## For now, we'll block URLs to keep this from being a source of spam
##
exclude "http://"

replies do |tweet|

  # replace the incoming username with the handle of the user who tweeted us
  src = tweet[:text].gsub(/@echoes_bot/, tweet_user(tweet))

  # send it back!
  reply src, tweet
end
