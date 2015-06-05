module Chatterbot

  #
  # simple twitter stream handler
  module Streaming
    #
    # handle searches
    # handle 
    #
    def handle_streaming_object(object)
      debug object

      case object
      when Twitter::Tweet
        if object.user == authenticated_user
          debug "skipping #{object} because it's from me"
        elsif (h = @handlers[:home_timeline]) && valid_tweet?(object)
          @current_tweet = object
          update_since_id(object)
          h.call(object)
          @current_tweet = nil
        end
      when Twitter::Streaming::DeletedTweet
        if (h = @handlers[:deleted])
          h.call(object)
        end
      when Twitter::DirectMessage
        if (h = @handlers[:direct_messages])
          @current_tweet = object
          update_since_id_dm(object)
          h.call(object)
          @current_tweet = nil
        end
      when Twitter::Streaming::Event
        if object.respond_to?(:source) && object.source == authenticated_user
          debug "skipping #{object} because it's from me"
        elsif object.name == :follow && (h = @handlers[:followed])
          h.call(object.source)
        elsif object.name == :favorite && (h = @handlers[:favorited])
          h.call(object.source, object.target_object)
        end
      when Twitter::Streaming::FriendList
        debug "got friend list"
      end
    end

  end   
end

