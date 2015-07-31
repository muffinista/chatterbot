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

    def interact_with_user?(t)
      return true unless only_interact_with_followers?
      u = t.respond_to?(:user) ? t.user : t
      client.friendship?(u, authenticated_user)
    end

    def valid_tweet?(object)
      if has_safelist? && ! on_safelist?(object)
        debug "skipping because user not on safelist"
        return false
      end

      !skippable_retweet?(object) && ! on_blocklist?(object) && ! skip_me?(object) && interact_with_user?(object)
    end

    #
    # Is this tweet from a user on our blocklist?
    def on_blocklist?(s)
      search = if s.is_a?(Twitter::User)
                 s.name
               elsif s.respond_to?(:user) && !s.is_a?(Twitter::NullObject)
                 from_user(s)
               else
                 s
               end.downcase

      blocklist.any? { |b| search.include?(b.downcase) }
    end

  end
end
