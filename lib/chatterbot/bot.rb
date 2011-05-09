module Chatterbot
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
      super

      # update config when we exit
      at_exit do
        raise $! if $!
        update_config
      end
    
    end
    
  end
end
