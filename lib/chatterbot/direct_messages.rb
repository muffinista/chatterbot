module Chatterbot
  #
  # handle Twitter DMs
  module DirectMessages
    #
    # send a direct message
    #
    def direct_message(txt, user=nil)
      return unless require_login

      if user.nil?
        user = current_user
      end
      client.create_direct_message(user, txt)
    end

    #
    # check direct messages for the bot
    #
    def direct_messages(opts = {}, &block)
      return unless require_login
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

