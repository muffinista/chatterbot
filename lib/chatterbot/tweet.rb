module Chatterbot

  #
  # routines for sending tweets
  module Tweet 
   
    # simple wrapper for sending a message
    def tweet(txt, params = {}, original = nil)
      return if require_login == false

      if debug_mode?
        debug "I'm in debug mode, otherwise I would tweet: #{txt}"
      else
        debug txt
        log txt, original
        client.update txt, params
      end
    end   

    # reply to a tweet
    def reply(txt, source)
      debug txt
      self.tweet txt, {:in_reply_to_status_id => source[:id]}, source
    end   
  end
end
