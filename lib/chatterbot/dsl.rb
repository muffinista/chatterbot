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

                 #
                 # parse any command-line options and use them to initialize the bot
                 #
                 params = {}

                 opts = OptionParser.new
                 opts.on('-d', '--db [ARG]')    { |d| ENV["chatterbot_db"] = d }
                 opts.on('-c', '--config [ARG]')    { |c| ENV["chatterbot_config"] = c }
                 opts.on('-t', '--test')    { params[:debug_mode] = true }
                 opts.on('-t', '--dry-run')    { params[:debug_mode] = true ; params[:no_update] = true }
                 opts.on('-s', '--since_id [ARG]')    { |s| params[:since_id] = s }
                 opts.parse!(ARGV)

                 Chatterbot::Bot.new(params)
               end
    end

    #
    # specify a bot-specific blacklist of users.  accepts an array, or a 
    # comma-delimited string
    def blacklist(b)
      if b.is_a?(String)
        b = b.split(",").collect { |s| s.strip }
      end
      bot.blacklist = b
    end

    #
    # specify list of strings we will check when deciding to respond to a tweet or not
    def exclude(e)
      if e.is_a?(String)
        e = e.split(",").collect { |s| s.strip }
      end
      bot.exclude = e
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
