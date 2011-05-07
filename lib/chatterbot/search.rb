module Chatterbot
  module Search
   
    def _search(query, &block)
      return unless init_client
      
      debug "check for tweets since #{since_id}"

      #
      # search twitter
      #
      search = client.search(query, default_opts)
      update_since_id(search)

      if search != nil
        search["results"].each { |s|
          yield s unless ! block_given? || on_blacklist?(s) || skip_me?(s)
        }
      end
    end
  
  end
end

