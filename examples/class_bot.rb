#!/usr/bin/env ruby

require 'chatterbot'


x = Chatterbot::Bot.new
x.search("foo") do |tweet|
  puts tweet.inspect
end
