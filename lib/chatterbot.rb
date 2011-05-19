#require 'rubygems'

require 'bundler/setup'
Bundler.require

#
# extend Hash class to turn keys into symbols
#
class Hash

  #
  # turn keys in this hash into symbols
  def symbolize_keys!
    replace(inject({}) do |hash,(key,value)|
      hash[key.to_sym] = value.is_a?(Hash) ? value.symbolize_keys! : value
      hash
    end)
  end
end

#
# the big kahuna!
module Chatterbot

  #
  # load in our assorted modules
  def self.load
    dir = File.dirname(__FILE__)
    require "#{dir}/chatterbot/config"
    require "#{dir}/chatterbot/db"
    require "#{dir}/chatterbot/logging"
    require "#{dir}/chatterbot/blacklist"
    require "#{dir}/chatterbot/client"
    require "#{dir}/chatterbot/search"
    require "#{dir}/chatterbot/tweet"
    require "#{dir}/chatterbot/reply"

    require "#{dir}/chatterbot/bot"
  end
end


# mount up
Chatterbot.load

