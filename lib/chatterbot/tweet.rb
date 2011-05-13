module Chatterbot

  #
  # routines for sending tweets
  module Tweet 

protected
    # simple wrapper for sending a message
    def _tweet(txt, params = {}, original = nil)
      require_login

      debug txt
      log txt, original

      client.update txt, params unless debug_mode?
    end   

    # reply to a tweet
    def _reply(txt, source)
      _tweet txt, {:in_reply_to_status_id => source["id"]}, source
    end   
  end
end
