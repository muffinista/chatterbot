module Botter
  class Bot
    include Blacklist
    include Config
    include Logging
    include Search
    include Tweet
    include Reply
    include Client

    include DSL

    def initialize
      load_config
      super

      # Run bot if macros has been used
      at_exit do
        raise $! if $!
        update_config
      end
    
    end
    
  end
end
