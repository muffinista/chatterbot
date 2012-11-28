#!/usr/bin/env ruby

require 'chatterbot/dsl'

exclude ["bar"]
search("foo", :lang => "en") do |tweet|
  puts tweet.inspect
end

