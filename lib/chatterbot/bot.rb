module Chatterbot

  #
  # primary Bot object, includes all the other modules
  class Bot
    include Utils
    include Blacklist
    include Whitelist
    include Streaming
    include Config
    include Logging
    include Search
    include HomeTimeline
    include Tweet
    include Profile
    include Retweet
    include Favorite
    include Reply
    include Followers
    include UI
    include Client
    include DB
    include Helpers

    #
    # Create a new bot. No options for now.
    def initialize(params={})
      if params.has_key?(:name)
        @botname = params.delete(:name)
      end

      @config = load_config(params)

      if reset_bot?
        reset_since_id
        update_config
        puts "Reset to #{@config[:since_id]}"
        exit
      else
        # update config when we exit
        at_exit do
          raise $! if $!
          update_config_at_exit
        end  
      end
    end
  end
end
