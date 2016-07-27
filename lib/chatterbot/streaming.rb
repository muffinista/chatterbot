module Chatterbot

  #
  # simple twitter stream handler
  module Streaming

    def streaming_tweet_handler
      usable_handlers = [:home_timeline, :search]
      name, block = @handlers.find { |k, v| usable_handlers.include?(k) }

       if block.nil? && ( block = @handlers[:replies] )
         debug "No default handler, wrapping the replies handler"
         return Proc.new { |tweet|
           if tweet.text =~ /^@#{bot.screen_name}/i
             block.call(tweet)
           end
         }
       end

       puts block.inspect
       block
    end
    
    #
    # Take the passed in object and call the appropriate bot method
    # for it
    # @param [Class] object a streaming API object
    #
    def handle_streaming_object(object)
      debug object

      case object
      when Twitter::Tweet
        if object.user == authenticated_user
          debug "skipping #{object} because it's from me"
        elsif (h = streaming_tweet_handler) && valid_tweet?(object)
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
        if object.sender == authenticated_user
          debug "skipping DM #{object} because it's from me"
        elsif (h = @handlers[:direct_messages])
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
      when Twitter::Streaming::StallWarning
        debug "***** STALL WARNING *****"
      end
    end

  end   
end

