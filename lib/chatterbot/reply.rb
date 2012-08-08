module Chatterbot

  #
  # reply method for responding to tweets
  module Reply

    # handle replies for the bot
    def replies(&block)
      return unless require_login

      debug "check for replies since #{since_id}"

      opts = since_id > 0 ? {:since_id => since_id} : {}
      opts[:count] = 200

      results = client.mentions(opts)
      results.each { |s|
        unless ! block_given? || on_blacklist?(s) || skip_me?(s)
          update_since_id(s)
          yield s         
        end
      }
    end
  end
end
