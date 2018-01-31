module Chatterbot

  #
  # handle Twitter searches
  module Search

    # set a reasonable limit on the maximum number of tweets we will
    # ever return. otherwise it is possible to exceed Twitter's rate limits
    MAX_SEARCH_TWEETS = 1000
    
    @skip_retweets = true
    
    #
    # exclude retweets from searches
    #
    def exclude_retweets
      @skip_retweets = true
    end

    #
    # include retweets from searches
    #
    def include_retweets
      @skip_retweets = false
    end

    
    #
    # check if this is a retweet that we want to skip
    #
    def skippable_retweet?(t)
      @skip_retweets && t.retweeted_status?
    end

    def wrap_search_query(q)
      if q =~ / /
        ['"', q.gsub(/^"/, '').gsub(/"$/, ''), '"'].join("")
      else
        q
      end
    end
    
    # internal search code
    def search(queries, opts = {}, &block)
      debug "check for tweets since #{since_id}"
      
      max_tweets = opts.delete(:limit) || MAX_SEARCH_TWEETS
      exact_match = if opts.key?(:exact)
                      opts.delete(:exact)
                    else
                      true
                    end
        
      
      if queries.is_a?(String)
        queries = [
          queries
        ]
      end

      query = queries.map { |q|
        if exact_match == true
          q = wrap_search_query(q)
        end

        q
      }.join(" OR ")
      
      #
      # search twitter
      #

      debug "search: #{query} #{default_opts.merge(opts)}"
      @current_tweet = nil

      client.search( query, default_opts.merge(opts) ).take(max_tweets).each { |s|
        update_since_id(s)
        debug s.text

        if block_given? && valid_tweet?(s)
          @current_tweet = s
          yield s
        end
      }
      @current_tweet = nil

    end
  
  end
end

