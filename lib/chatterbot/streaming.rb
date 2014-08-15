module Chatterbot

  #
  # simple twitter stream handler
  module Streaming

    def authenticated_user
      @user ||= client.user
    end
    
    # Streams messages for a single user, optionally including an
    # additional search/etc
    #
    # @param opts [Hash] options
    # @option options [String] :with Specifies whether to return information for just the users specified in the follow parameter, or include messages from accounts they follow.
    # @option options [String] :replies Specifies whether to return additional @replies.
    # @option options [String] :stall_warnings Specifies whether stall warnings should be delivered.
    # @option options [String] :track Includes additional Tweets matching the specified keywords. Phrases of keywords are specified by a comma-separated list.
    # @option options [String] :locations Includes additional Tweets falling within the specified bounding boxes.
    # @yield [Twitter::Tweet, Twitter::Streaming:
    def do_streaming(streamer)
      debug "streaming twitter client"
      streaming_client.send(streamer.endpoint, streamer.connection_params) do |object|
        handle_streaming_object(object, streamer)
      end    
    end

    def handle_streaming_object(object, streamer)
      debug object

      case object
      when Twitter::Tweet
        if object.user == authenticated_user
          debug "skipping #{object} because it's from me"
        elsif streamer.tweet_handler && !on_blacklist?(object) && !skip_me?(object)
          @current_tweet = object
          streamer.tweet_handler.call object
          @current_tweet = nil
        end
      when Twitter::Streaming::DeletedTweet
        if streamer.delete_handler
          streamer.delete_handler.call(object)
        end
      when Twitter::DirectMessage
        if streamer.dm_handler # && !on_blacklist?(object) && !skip_me?(object)
          @current_tweet = object
          streamer.dm_handler.call object
          @current_tweet = nil
        end
      when Twitter::Streaming::Event
        if object.respond_to?(:source) && object.source == authenticated_user
          debug "skipping #{object} because it's from me"
        elsif object.name == :follow && streamer.follow_handler
          streamer.follow_handler.call(object.source)
        elsif object.name == :favorite && streamer.favorite_handler
          streamer.favorite_handler.call(object.source, object.target_object)
        end
      when Twitter::Streaming::FriendList
        debug "got friend list"
        if streamer.friends_handler
          streamer.friends_handler.call(object)
        end
      end
    end
  end
end

