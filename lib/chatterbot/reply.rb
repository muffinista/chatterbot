module Chatterbot

  #
  # reply method for responding to tweets
  module Reply

    # handle replies for the bot
    def replies(&block)
      return unless require_login
      debug "check for replies since #{since_id}"
      
      results = client.replies(:since_id => since_id)

      if results.is_a?(Hash) && results.has_key?("error")
        critical results["error"]
      else
        results.each { |s|
          s.symbolize_keys!
          unless ! block_given? || on_blacklist?(s) || skip_me?(s)
            update_since_id(s)
            yield s         
          end
        }
      end
    end

  end
end
