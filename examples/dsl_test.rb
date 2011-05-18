#!/usr/bin/env ruby

require '../lib/chatterbot'

exclude ["foo", "bar"]
search("foo") do |tweet|
# #  reply "@#{tweet['from_user']} I am serious, and don't call me Shirley!", tweet
  puts tweet.inspect
end
