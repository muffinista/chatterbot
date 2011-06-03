module Chatterbot

  #
  # primary Bot object, includes all the other modules
  class Bot
    include Blacklist
    include Config
    include Logging
    include Search
    include Tweet
    include Reply
    include Client
    include DB
    include Helpers

    #
    # Create a new bot. No options for now.
    def initialize(params={})
      @config = load_config(params)
      
      # update config when we exit
      at_exit do
        raise $! if $!
        update_config
      end  
    end
    
  end
end
