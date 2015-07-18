require 'yaml'
require 'oauth'
require 'twitter'
require 'launchy'
require 'colorize'


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
  @@from_helper = false

  #
  # load in our assorted modules
  def self.load
    require "chatterbot/config_manager"
    require "chatterbot/config"
    require "chatterbot/logging"
    require "chatterbot/blocklist"
    require "chatterbot/safelist"
    require "chatterbot/ui"
    require "chatterbot/client"    
    require "chatterbot/search"
    require "chatterbot/direct_messages"    
    require "chatterbot/tweet"
    require "chatterbot/retweet"
    require "chatterbot/favorite"
    require "chatterbot/profile"
    require "chatterbot/reply"
    require "chatterbot/home_timeline"
    require "chatterbot/followers"
    require "chatterbot/helpers"
    require "chatterbot/utils"
    require "chatterbot/streaming"

    require "chatterbot/bot"
  end

  # setter to track if we're being called from a helper script
  def self.from_helper=(x)
    @@from_helper = x
  end

  # are we being called from a helper script?
  def self.from_helper
    @@from_helper
  end
  
  require 'chatterbot/version'
  
  # Return a directory with the project libraries.
  def self.libdir
    t = [File.expand_path(File.dirname(__FILE__)), "#{Gem.dir}/gems/chatterbot-#{Chatterbot::VERSION}"]

    t.each {|i| return i if File.readable?(i) }
    raise "both paths are invalid: #{t}"
  end
end


# mount up
Chatterbot.load
