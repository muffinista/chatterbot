module Chatterbot

  #
  # methods for preventing the bot from spamming people who don't want to hear from it
  module Blacklist
    attr_accessor :exclude, :blacklist

    # return a list of text strings which we will check for in incoming tweets.
    # If the text is listed, we won't use this tweet
    def exclude
      @exclude || []
    end
    
    # A list of Twitter users that don't want to hear from the bot.
    def blacklist
      @blacklist || []
    end
    def blacklist=(b)
      @blacklist = b
    end
    
    #
    # Based on the text of this tweet, should it be skipped?
    def skip_me?(s)
      search = s.respond_to?(:text) ? s.text : s
      exclude.detect { |e| search.downcase.include?(e) } != nil
    end
    
    #
    # Is this tweet from a user on our blacklist?
    def on_blacklist?(s)
      search = (s.respond_to?(:user) ? from_user(s) : s).downcase
      blacklist.any? { |b| search.include?(b.downcase) } ||
        on_global_blacklist?(search)
    end

    #
    # Is this user on our global blacklist?
    def on_global_blacklist?(user)
      return false if ! has_db?
      db[:blacklist].where(:user => user).count > 0
    end

    #
    # add the specified user to the global blacklist
    def add_to_blacklist(user)    
      user = user.is_a?(Hash) ? user[:from_user] : user
      
      # don't try and add if we don't have a DB connection, or if the
      # user is already on the list
      return if ! has_db? || on_global_blacklist?(user)

      # make sure we don't have an @ at the beginning of the username
      user.gsub!(/^@/, "")
      debug "adding #{user} to blacklist"

      db[:blacklist].insert({ :user => user, :created_at => Time.now }) # 
    end
    
  end
end
