module Botter
  module Tweet 
    # simple wrapper for sending a message
    def _tweet(txt, params = {}, original = nil)
      require_login

      debug txt
      log txt, original

      client.update txt, params unless debug_mode?
    end   

    def _reply(txt, source)
      _tweet txt, {:in_reply_to_status_id => source["id"]}, source
    end   
  end
end
