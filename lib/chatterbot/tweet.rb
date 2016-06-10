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
        if params.has_key?(:media)
          file = params.delete(:media)
          if ! file.is_a?(File)
            file = File.new(file)
          end

          client.update_with_media txt, file, params
        else
          client.update txt, params
        end
      end
    rescue Twitter::Error::Forbidden => e
      #:nocov:
      debug e
      false
      #:nocov:
    end

    
    # reply to a tweet
    def reply(txt, source, params = {})
      debug txt
      params = {:in_reply_to_status_id => source.id}.merge(params)
      tweet txt, params, source
    end
  end
end
