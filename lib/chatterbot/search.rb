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
      return unless init_client
      
      debug "check for tweets since #{since_id}"

      if queries.is_a?(String)
        queries = [queries]
      end
      
      #
      # search twitter
      #
      queries.each { |query|

        query = exclude_retweets(query)

        search = client.search(query, opts.merge(default_opts))
        update_since_id(search)

        if search != nil
          search["results"].each { |s|
            s.symbolize_keys!
            yield s unless ! block_given? || on_blacklist?(s) || skip_me?(s)
          }
        end
      }
    end
  
  end
end

