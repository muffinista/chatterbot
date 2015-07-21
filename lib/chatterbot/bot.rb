module Chatterbot
  require 'chatterbot/handler'

  #
  # primary Bot object, includes all the other modules
  class Bot
    include Utils
    include Streaming
    include Blocklist
    include Safelist
    include Config
    include Logging
    include Search
    include DirectMessages
    include HomeTimeline
    include Tweet
    include Profile
    include Retweet
    include Favorite
    include Reply
    include Followers
    include UI
    include Client
    include Helpers

    # handlers that can use the REST API
    HANDLER_CALLS = [:direct_messages, :home_timeline, :replies, :search]

    # handlers that require the Streaming API
    STREAMING_ONLY_HANDLERS = [:favorited, :followed, :deleted]
    
    #
    # Create a new bot. No options for now.
    def initialize(params={})
      if params.has_key?(:name)
        @botname = params.delete(:name)
      end

      @config = load_config(params)
      @run_count = 0

      #
      # check for command line options
      # handle resets, etc
      #

      at_exit do
        if @run_count <= 0 && skip_run? != true
          run_or_stream
        end
        
        raise $! if $!
      end
      @handlers = {}
    end

    #
    # determine the right API to use and run the bot
    #
    def run_or_stream
      @run_count += 1
      if streaming?
        stream!
      else
        run!
      end
    end

    #
    # run the bot with the Streaming API
    #
    def stream!
      before_run
      streaming_client.user do |object|
        handle_streaming_object(object)
      end
      after_run
    end

    #
    # run the bot with the REST API
    #
    def run!
      before_run

      HANDLER_CALLS.each { |c|
        if (h = @handlers[c])
          puts "calling #{c} #{h.opts.inspect}"
          send(c, h.opts) do |obj|
            h.call(obj)
          end
        end
      }

      after_run
    end


    def before_run
      @run_count = @run_count + 1
    end

    def after_run

    end

    def register_handler(method, opts = nil, &block)
      if STREAMING_ONLY_HANDLERS.include?(method)
        puts "Forcing usage of Streaming API to support #{method} calls"
        self.streaming = true
      end

      # @todo raise error if method already defined
      @handlers[method] = Handler.new(opts, &block)

    end
  end
end
