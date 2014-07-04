module Chatterbot

  # routines for retweet
  module Retweet 

    # simple wrapper for retweeting a message
    # @param [id] id A tweet or the ID of a tweet. if not specified,
    # tries to use the current tweet if available
    def retweet(id=@current_tweet)
      return if require_login == false || id.nil?

      id = id_from_tweet(id)
      #:nocov:
      if debug_mode?
        debug "I'm in debug mode, otherwise I would retweet with tweet id: #{id}"
        return
      end
      #:nocov:
      
      client.retweet id
    end
  end
end
