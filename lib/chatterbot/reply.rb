module Chatterbot

  #
  # handle checking for mentions of the bot
  module Reply

    # handle replies for the bot
    def replies(*args, &block)
      return unless require_login

      debug "check for replies since #{since_id_reply}"

      opts = {
        :since_id => since_id_reply,
        :count => 200
      }

      results = client.mentions_timeline(opts)
      @current_tweet = nil
      results.each { |s|
        update_since_id_reply(s)
        if block_given? && valid_tweet?(s)
          @current_tweet = s
          yield s         
        end
      }
      @current_tweet = nil
    end
  end
end
