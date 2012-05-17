module Chatterbot

  #
  # a bunch of helper routines for bots
  module Helpers
    def botname=(b)
      @botname = b
    end

    #
    # The name of the currently running bot
    def botname
      if !@botname.nil?
        @botname
      elsif self.class < Bot
        self.class.to_s.downcase
      else
        File.basename($0,".rb")
      end
    end

    #
    # Pull the username from a tweet hash -- this is different depending on
    # if we're doing a search, or parsing through replies/mentions.
    def from_user(s)
      return s if s.is_a?(String)
      return s.from_user if s.respond_to?(:from_user) #&& ! s.from_user.nil?
#      return s.user.screen_name if s.respond_to?(:user)

      s.has_key?(:from_user) ? s[:from_user] : s[:user][:screen_name]
    end

    
    #
    # Take the incoming tweet/user name, and turn it into something suitable for replying 
    # to a user. Basically, get their handle and add a '@' to it.
    def tweet_user(tweet)     
      base = from_user(tweet)
      base =~ /^@/ ? base : "@#{base}"
    end


    #
    # do some simple variable substitution.  for now, it only handles
    # replacing #USER# with the screen of the incoming tweet, but it
    # could do more if needed
    #
    def replace_variables(txt, original = nil)
      if ! original.nil? && txt.include?("#USER#")
        username = tweet_user(original)
        txt.gsub("#USER#", username)
      else
        txt
      end
    end

  end
end
