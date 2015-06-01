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
      blocklist.any? { |b| search.include?(b.downcase) } ||
        on_global_blocklist?(search)
    end

    #
    # Is this user on our global blocklist?
    def on_global_blocklist?(user)
      return false if ! has_db?
      db[:blocklist].where(:user => user).count > 0
    end

    #
    # add the specified user to the global blocklist
    def add_to_blocklist(user)    
      user = user.is_a?(Hash) ? user[:from_user] : user
      
      # don't try and add if we don't have a DB connection, or if the
      # user is already on the list
      return if ! has_db? || on_global_blocklist?(user)

      # make sure we don't have an @ at the beginning of the username
      user.gsub!(/^@/, "")
      debug "adding #{user} to blocklist"

      db[:blocklist].insert({ :user => user, :created_at => Time.now }) # 
    end
    
  end
end
