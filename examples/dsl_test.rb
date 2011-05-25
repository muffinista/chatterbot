#!/usr/bin/env ruby

require 'chatterbot/dsl'

exclude ["foo", "bar"]
search("foo") do |tweet|
# #  reply "@#{tweet['from_user']} I am serious, and don't call me Shirley!", tweet
  puts tweet.inspect
end
