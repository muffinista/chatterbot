require File.join(File.dirname(__FILE__), '..', 'chatterbot')
require 'optparse'

module Chatterbot
  #
  # very basic DSL to handle the common stuff you would want to do with a bot.
  module DSL

    #
    # generate a Bot object. if the DSL is being called from a Bot object, just return it
    # otherwise create a bot and return that
    def bot
      return @bot unless @bot.nil?
      
      #
      # parse any command-line options and use them to initialize the bot
      #
      params = {}
      
      opts = OptionParser.new

      opts.banner = "Usage: #{File.basename($0)} [options]"

      opts.separator ""
      opts.separator "Specific options:" 
      
      opts.on('-d', '--db [ARG]', "Specify a DB connection URI")    { |d| ENV["chatterbot_db"] = d }
      opts.on('-c', '--config [ARG]', "Specify a config file to use")    { |c| ENV["chatterbot_config"] = c }
      opts.on('-t', '--test', "Run the bot without actually sending any tweets") { params[:debug_mode] = true }
      opts.on('-v', '--verbose', "verbose output to stdout")    { params[:verbose] = true }
      opts.on('--dry-run', "Run the bot in test mode, and also don't update the database")    { params[:debug_mode] = true ; params[:no_update] = true }
      opts.on('-s', '--since_id [ARG]', "Check for tweets since tweet id #[ARG]")    { |s| params[:since_id] = s.to_i }

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end      
      
      opts.parse!(ARGV)

      @bot = Chatterbot::Bot.new(params)
    end

    #
    # should we send tweets?
    #
    def debug_mode(d=nil)
      d = true if d.nil?
      bot.debug_mode = d
    end

    #
    # should we update the db with a new since_id?
    #
    def no_update(d=nil)
      d = true if d.nil?
      bot.no_update = d
    end

    #
    # turn on/off verbose output
    #
    def verbose(d=nil)
      d = true if d.nil?
      bot.verbose = d
    end

    #
    # take a variable list of strings and possibly arrays and turn
    # them into a single flat array of strings
    #
    def flatten_list_of_strings(args)
      args.collect do |b|
        if b.is_a?(String)
          # string, split on commas and turn into array
          b.split(",").collect { |s| s.strip }
        else
          # presumably an array
          b
        end
      end.flatten
    end
    
    #
    # specify a bot-specific blacklist of users.  accepts an array, or a 
    # comma-delimited string
    def blacklist(*args)
      list = flatten_list_of_strings(args)
      
      if list.nil? || list.empty?
        bot.blacklist = []
      else     
        bot.blacklist += list
      end
    end
    
    #
    # specify list of strings we will check when deciding to respond to a tweet or not
    def exclude(*args)
      e = flatten_list_of_strings(args)
      if e.nil? || e.empty?
        bot.exclude = []
      else     
        bot.exclude += e
      end
    end
    
    #
    # search twitter for the specified terms
    def search(query, opts = {}, &block)
      bot.search(query, opts, &block)
    end
    
    #
    # handle replies to the bot
    def replies(&block)
      bot.replies(&block)
    end

    #
    # send a tweet
    def tweet(txt, params = {}, original = nil)
      bot.tweet(txt, params, original)
    end   

    #
    # reply to a tweet
    def reply(txt, source)
      bot.reply(txt, source)
    end
  end
end

include Chatterbot::DSL
include Chatterbot::Helpers
