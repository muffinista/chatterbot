module Chatterbot

  #
  # simple twitter stream handler
  module Streaming

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
    def streaming_tweets(opts = {}, &block)
      debug "streaming twitter client"

      opts = {
        :with => false,
        :replies => true,
        :stall_warnings => false
      }.merge(opts)

      # convert true/false to strings
      opts.each { |k, v| opts[k] = v.to_s }
      
      streaming_client.user(opts) do |object|
        case object
        when Twitter::Tweet
          debug object.text
          if block_given? && !on_blacklist?(object) && !skip_me?(object)
            @current_tweet = object
            yield object
            @current_tweet = nil
          end
        #when Twitter::DirectMessage
        #  debug "Received a DM, not doing anything"
        end
      end
      
    end  
  end
end

