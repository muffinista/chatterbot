module Chatterbot

  #
  # handle Twitter searches
  module Search

    MAX_SEARCH_TWEETS = 1000
    
    @skip_retweets = true
    
    #
    # modify a query string to exclude retweets from searches
    #
    def exclude_retweets
      @skip_retweets = true
    end

    def include_retweets
      @skip_retweets = false
    end

    def skippable_retweet?(t)
      @skip_retweets && t.retweeted_status?
    end
    
    # internal search code
    def search(queries, opts = {}, &block)
      debug "check for tweets since #{since_id}"

      max_tweets = opts.delete(:limit) || MAX_SEARCH_TWEETS
      
      if queries.is_a?(String)
        queries = [queries]
      end

      #
      # search twitter
      #
      queries.each { |query|
        debug "search: #{query} #{default_opts.merge(opts)}"
        @current_tweet = nil
        client.search( query, default_opts.merge(opts) ).take(max_tweets).each { |s|
          update_since_id(s)
          debug s.text
          if has_whitelist? && !on_whitelist?(s)
            debug "skipping because user not on whitelist"
          elsif block_given? && !on_blacklist?(s) && !skip_me?(s) && !skippable_retweet?(s)
            @current_tweet = s
            yield s
          end
        }
        @current_tweet = nil
      }
    end
  
  end
end

