module Chatterbot

  # routines for favorites
  module Favorite

    # simple wrapper for favoriting a message
    # @param [id] id A tweet or the ID of a tweet. if not specified,
    # tries to use the current tweet if available
    def favorite(id=@current_tweet)
      return if require_login == false

      id = id_from_tweet(id)
      
      #:nocov:
      if debug_mode?
        debug "I'm in debug mode, otherwise I would favorite tweet id: #{id}"
        return
      end
      #:nocov:
      client.favorite id
    end
  end
end
