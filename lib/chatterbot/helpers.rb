module Chatterbot

  #
  # a bunch of helper routines for bots
  module Helpers

    #
    # Set the username of the bot. This is used when generating
    # config/skeleton file during registration
    #
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
      case s
      when Twitter::Tweet
        s.user.screen_name
      when Twitter::User
        s.name
      when String
        s
      end
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

    #
    # find the user of the current tweet/object we are dealing with
    #
    def current_user
      return nil if @current_tweet.nil?
      return @current_tweet.sender if @current_tweet.respond_to?(:sender)
      return @current_tweet.user
    end
  end
end
