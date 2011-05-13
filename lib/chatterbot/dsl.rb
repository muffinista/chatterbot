module Chatterbot

  #
  # very basic DSL to handle the common stuff you would want to do with a bot.
  module DSL

    #
    # generate a Bot object. if the DSL is being called from a Bot object, just return it
    # otherwise create a bot and return that
    def bot
      @bot ||= if self.kind_of?(Chatterbot::Bot)
                 self
               else
                 Chatterbot::Bot.new
               end
    end

    #
    # search twitter for the specified terms
    def search(query, &block)
      bot._search(query, &block)
    end
    
    #
    # handle replies to the bot
    def replies(&block)
      bot._replies(&block)
    end

    #
    # send a tweet
    def tweet(txt, params = {}, original = nil)
      bot._tweet(txt, params, original)
    end   

    #
    # reply to a tweet
    def reply(txt, source)
      bot._reply(txt, source)
    end
  end
end

include Chatterbot::DSL
