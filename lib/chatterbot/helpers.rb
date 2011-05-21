module Chatterbot

  #
  # a bunch of helper routines for bots
  module Helpers

    #
    # Take the incoming tweet/user name, and turn it into something suitable for replying 
    # to a user. Basically, get their handle and add a '@' to it.
    def tweet_user(tweet)     
      if ! tweet.is_a?(String)
        base = tweet.has_key?(:from_user) ? tweet[:from_user] : tweet[:user][:screen_name]
      else
        base = tweet
      end
      base =~ /^@/ ? base : "@#{base}"
    end
  end
end
