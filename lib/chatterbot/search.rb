module Chatterbot

  #
  # handle Twitter searches
  module Search

    #
    # modify a query string to exclude retweets from searches
    #
    def exclude_retweets(q)
      q.include?("include:retweets") ? q : q += " -include:retweets"
    end
    
    # internal search code
    def search(queries, opts = {}, &block)
      debug "check for tweets since #{since_id}"

      if queries.is_a?(String)
        queries = [queries]
      end

      
      #
      # search twitter
      #
      queries.each { |query|
        debug "search: #{query} #{default_opts.merge(opts)}"
        result = client.search(
                                      exclude_retweets(query),
                                      default_opts.merge(opts)
                                      )
        update_since_id(result)

        @current_tweet = nil
        result.each { |s|
          debug s.text
          if block_given? && !on_blacklist?(s) && !skip_me?(s)
            @current_tweet = s
            yield s
          end
        }
        @current_tweet = nil
      }
    end
  
  end
end

