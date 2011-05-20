#require 'rubygems'

require 'bundler/setup'
Bundler.require

#
# Try and load Sequel, but don't freak out if it's not there
begin
  require 'sequel'
rescue Exception
end


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
    require "chatterbot/config"
    require "chatterbot/db"
    require "chatterbot/logging"
    require "chatterbot/blacklist"
    require "chatterbot/client"
    require "chatterbot/search"
    require "chatterbot/tweet"
    require "chatterbot/reply"
    require "chatterbot/helpers"    

    require "chatterbot/bot"
  end
end


# mount up
Chatterbot.load

