module Chatterbot

  # routines for retweet
  module Retweet 

    # simple wrapper for retweeting a message
    def retweet(id)
      return if require_login == false

      if debug_mode?
        debug "I'm in debug mode, otherwise I would retweet with tweet id: #{id}"
      else
        client.retweet id
      end
    end
  end
end
