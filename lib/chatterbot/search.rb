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
        debug "search: #{query} #{opts.merge(default_opts)}"
        result = search_client.search(
                                      exclude_retweets(query),
                                      opts.merge(default_opts)
                                      )
        update_since_id(result.max_id)

        result.collection.each { |s|
          debug s.text
          yield s unless ! block_given? || on_blacklist?(s) || skip_me?(s)
        }
      }
    end
  
  end
end

