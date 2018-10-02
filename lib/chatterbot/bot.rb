module Chatterbot
  require 'chatterbot/handler'

  #
  # primary Bot object, includes all the other modules
  class Bot
    include Utils
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
          run!
        end
        
        raise $! if $!
      end
      @handlers = {}
    end

    def screen_name
      @screen_name ||= client.settings.screen_name
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
      true
    end
    
    def register_handler(method, opts = nil, &block)
      # @todo raise error if method already defined
      @handlers[method] = Handler.new(opts, &block)

      h = @handlers[method]
      self.send(method, *(h.opts)) do |obj|
        h.call(obj)
      end
    end
  end
end
