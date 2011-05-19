module Chatterbot

  #
  # a bunch of helper routines for bots
  module Helpers
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
