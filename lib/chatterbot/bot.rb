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
        if !@handlers.empty? && @run_count <= 0 && skip_run? != true
          run_or_stream
        end
        
        raise $! if $!
      end
      @handlers = {}
    end

    def screen_name
      @screen_name ||= client.settings.screen_name
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

      #
      # figure out how we want to call streaming client
      #
      if @handlers[:search]
        method = :filter
        args = streamify_search_options(@handlers[:search].opts)
      else
        method = :user
        args = {
          stall_warnings: "true"
        }
      end

      streaming_client.send(method, args) do |object|
        handle_streaming_object(object)
      end
      after_run
    end

    #
    # the REST API and Streaming API have a slightly different format.
    # tweak our search handler to switch from REST to Streaming
    #
    def streamify_search_options(opts)
      if opts.is_a?(String)
        { track: opts }
      elsif opts.is_a?(Array)
        { track: opts.join(", ") }
      else
        opts
      end
    end
    
    #
    # run the bot with the REST API
    #
    def run!
      before_run

      HANDLER_CALLS.each { |c|
        if (h = @handlers[c])
          send(c, *(h.opts)) do |obj|
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

    def call_api_immediately?
      !streaming?
    end
    
    def register_handler(method, opts = nil, &block)
      # @todo raise error if method already defined
      @handlers[method] = Handler.new(opts, &block)

      if STREAMING_ONLY_HANDLERS.include?(method)
        puts "Forcing usage of Streaming API to support #{method} calls"
        self.streaming = true
      elsif call_api_immediately?
        @run_count += 1
        h = @handlers[method]
        self.send(method, *(h.opts)) do |obj|
          h.call(obj)
        end
      end
     
    end
  end
end
