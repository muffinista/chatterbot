#!/usr/bin/env ruby

#
# require the dsl lib to include all the methods you see below.
#
require 'rubygems'
require 'chatterbot/dsl'

puts "Loading search_bot.rb"

##
## If I wanted to exclude some terms from triggering this bot, I would list them here.
## For now, we'll block URLs to keep this from being a source of spam
##
exclude "http://"

blacklist "mean_user, private_user"

search("twitter", :lang => "en") do |tweet|
  puts tweet[:text]
end

