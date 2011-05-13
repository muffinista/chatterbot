module Chatterbot

  #
  # reply method for responding to tweets
  module Reply
    protected

    # handle replies for the bot
    def _replies(&block)
      return unless require_login
      debug "check for replies since #{since_id}"
      
      client.replies(:since_id => since_id).each { |s|
        unless !block_given? || on_blacklist?(s) || skip_me?(s)
          update_since_id(s)
          yield s         
        end
      }
    end

  end
end
