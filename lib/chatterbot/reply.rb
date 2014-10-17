module Chatterbot

  #
  # handle checking for mentions of the bot
  module Reply

    # handle replies for the bot
    def replies(&block)
      return unless require_login

      debug "check for replies since #{since_id_reply}"

      opts = {}
      if since_id_reply > 0
        opts[:since_id] = since_id_reply
      elsif since_id > 0
        opts[:since_id] = since_id
      end
      opts[:count] = 200

      results = client.mentions_timeline(opts)
      @current_tweet = nil
      results.each { |s|
        update_since_id_reply(s)
        if has_whitelist? && !on_whitelist?(s)
          debug "skipping because user not on whitelist"
        elsif block_given? && !on_blacklist?(s) && !skip_me?(s)
          @current_tweet = s
          yield s         
        end
      }
      @current_tweet = nil
    end
  end
end
