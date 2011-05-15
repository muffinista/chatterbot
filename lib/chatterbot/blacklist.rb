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

    # Based on the text of this tweet, should it be skipped?
    def skip_me?(s)
      search = s.is_a?(Hash) ? s["text"] : s
      exclude.detect { |e| search.downcase.include?(e) } != nil
    end

    # Is this tweet from a user on our blacklist?
    def on_blacklist?(s)
      search = s.is_a?(Hash) ? s["from_user"] : s     
      total_blacklist.detect { |b| search.downcase.include?(b.downcase) } != nil
    end

    # the list of users from this bot's blacklist, as well as the global
    # db blacklist, if available
    def total_blacklist
      @_blacklist ||= blacklist + load_global_blacklist
    end

    #
    # add the specified user to the global blacklist
    def add_to_blacklist(user)    
      user = user.is_a?(Hash) ? user["from_user"] : user
      return if ! has_db? || on_blacklist?(user)

      # make sure we don't have an @ at the beginning of the username
      user.gsub!(/^@/, "")

      debug "adding #{user} to blacklist"

      db[:blacklist].insert({ :user => user, :created_at => Time.now }) # 'NOW()'.lit
    end

    #
    # load our global blacklist from the database
    def load_global_blacklist
      return [] if ! has_db?
      db[:blacklist].collect{ |x| x[:user] }
    end

  end
end
