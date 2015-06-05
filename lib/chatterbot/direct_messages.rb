module Chatterbot

  #
  # handle Twitter DMs
  module DirectMessages
    # internal search code
    def direct_messages(opts = {}, &block)
      puts opts.inspect
      puts block.inspect

      debug "check for DMs since #{since_id_dm}"
            
      #
      # search twitter
      #

      @current_tweet = nil
      client.direct_messages_received(since_id:since_id_dm, count:200).each { |s|
        update_since_id_dm(s)
        debug s.text
        if has_safelist? && !on_safelist?(s.sender)
          debug "skipping because user not on safelist"
        elsif block_given? && !on_blocklist?(s.sender) && !skip_me?(s)
          @current_tweet = s
          yield s
        end
      }
      @current_tweet = nil
    rescue Twitter::Error::Forbidden => e
      puts "sorry, looks like we're not allowed to check DMs for this account"
    end
  
  end
end

