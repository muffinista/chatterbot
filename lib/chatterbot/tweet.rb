module Chatterbot

  #
  # routines for sending tweets
  module Tweet 
    # simple wrapper for sending a message
    def tweet(txt, params = {}, original = nil)
      return if require_login == false

      txt = replace_variables(txt, original)
      
      if debug_mode?
        debug "I'm in debug mode, otherwise I would tweet: #{txt}"
      else
        debug txt
        client.update txt, params
      end
    rescue Twitter::Error::Forbidden => e
      #:nocov:
      debug e
      false
      #:nocov:
    end


    def tweet_with_media(txt, media, params = {}, original = nil)
    
      txt = replace_variables(txt, original)
    
      if debug_mode?
        debug "I'm in debug mode, otherwise I would tweet: #{txt}"
      else
        debug txt
        client.update_with_media(txt, File.new(media))
      end
    rescue Twitter::Error::Forbidden => e
      #:nocov:
      debug e
      false
      #:nocov:
    end
    
    
    # reply to a tweet
    def reply(txt, source)
      debug txt
      tweet txt, {:in_reply_to_status_id => source.id}, source
    end
    
    # reply to a tweet with media
    def reply_with_media(txt, media, source)
      debug txt
      client.update_with_media(txt, File.new(media), {:in_reply_to_status_id => source.id})
    end
  end
end
