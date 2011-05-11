module Chatterbot
  module DSL

    #
    # if we've been included in a Bot object, just return it
    # otherwise create a bot and return that
    #
    def bot
      @bot ||= if self.kind_of?(Chatterbot::Bot)
                 self
               else
                 Chatterbot::Bot.new
               end
    end
    
    def search(query, &block)
      bot._search(query, &block)
    end
    
    def replies(&block)
      bot._replies(&block)
    end

    def tweet(txt, params = {}, original = nil)
      bot._tweet(txt, params, original)
    end   

    def reply(txt, source)
      bot._reply(txt, source)
    end
  end
end

include Chatterbot::DSL
