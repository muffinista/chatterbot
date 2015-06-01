module Chatterbot

  #
  # methods for preventing the bot from spamming people who don't want to hear from it
  module Blocklist
    attr_accessor :exclude, :blocklist

    alias :blacklist :blocklist
    
    # return a list of text strings which we will check for in incoming tweets.
    # If the text is listed, we won't use this tweet
    def exclude
      @exclude || []
    end
    
    # A list of Twitter users that don't want to hear from the bot.
    def blocklist
      @blocklist || []
    end
    def blocklist=(b)
      @blocklist = b
    end
    
    #
    # Based on the text of this tweet, should it be skipped?
    def skip_me?(s)
      search = s.respond_to?(:text) ? s.text : s
      exclude.detect { |e| search.downcase.include?(e) } != nil
    end
    
    #
    # Is this tweet from a user on our blocklist?
    def on_blocklist?(s)
      search = (s.respond_to?(:user) ? from_user(s) : s).downcase
      blocklist.any? { |b| search.include?(b.downcase) }
    end
    
  end
end
