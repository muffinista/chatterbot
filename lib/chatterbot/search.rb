module Chatterbot

  #
  # handle Twitter searches
  module Search

    # internal search code
    def _search(queries, &block)
      return unless init_client
      
      debug "check for tweets since #{since_id}"

      if queries.is_a?(String)
        queries = [queries]
      end
      
      #
      # search twitter
      #
      queries.each { |query|
        search = client.search(query, default_opts)
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

