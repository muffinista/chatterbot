require File.join(File.dirname(__FILE__), '..', 'chatterbot')
require 'optparse'

module Chatterbot
  #
  # very basic DSL to handle the common stuff you would want to do with a bot.
  module DSL
    def client
      bot.client
    end
    
    #
    # search twitter for the specified terms, then pass any matches to
    # the block.
    # @example
    #   search("chatterbot is cool!") do |tweet|
    #     puts tweet.text # this is the actual tweeted text
    #     reply "I agree!", tweet
    #   end
    def search(query, opts = {}, &block)
      bot.search(query, opts, &block)
    end

    #
    # handle replies to the bot. Each time this is called, chatterbot
    # will pass any replies since the last call to the specified block
    #
    # @example
    #   replies do |tweet|
    #     puts tweet.text # this is the actual tweeted text
    #     reply "Thanks for the mention!", tweet
    #   end
    def replies(&block)
      bot.replies(&block)
    end

    #
    # send a tweet
    #
    # @param [String] txt the text you want to tweet
    # @param [Hash] params opts for the tweet
    #   @see http://rdoc.info/gems/twitter/Twitter/API#update-instance_method
    # @param [Tweet] original if this is a reply, the original tweet. this will
    #   be used for variable substitution, and for logging
    def tweet(txt, params = {}, original = nil)
      bot.tweet(txt, params, original)
    end

    #
    # retweet a tweet
    # @param [id] id the ID of the tweet
    def retweet(id)
      bot.retweet(id)
    end

    #
    # reply to a tweet
    #
    # @param [String] txt the text you want to tweet
    # @param [Tweet] source the original tweet you are replying to
    def reply(txt, source)
      bot.reply(txt, source)
    end

    
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
      opts.on('-m', '--since_id_reply [ARG]', "Check for mentions since tweet id #[ARG]")    { |s| params[:since_id_reply] = s.to_i }
      opts.on('-r', '--reset', "Reset your bot to ignore old tweets") {
        params[:debug_mode] = true
        params[:reset_since_id] = true
      }

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end

      opts.parse!(ARGV)

      @bot = Chatterbot::Bot.new(params)
    end

    #
    # should we send tweets?
    # @param [Boolean] d true/false if we should send tweets
    #
    def debug_mode(d=nil)
      d = true if d.nil?
      bot.debug_mode = d
    end

    #
    # should we update the db with a new since_id?
    # @param [Boolean] d true/false if we should update the database
    #
    def no_update(d=nil)
      d = true if d.nil?
      bot.no_update = d
    end

    #
    # turn on/off verbose output
    # @param [Boolean] d true/false use verbose output
    #
    def verbose(d=nil)
      d = true if d.nil?
      bot.verbose = d
    end

    #
    # specify a bot-specific blacklist of users.  accepts an array, or a
    # comma-delimited string. when called, any subsequent calls to
    # search or replies will filter out these users.
    #
    # @param [Array, String] args list of usernames
    # @example
    #   blacklist "mean_user, private_user"
    #
    def blacklist(*args)
      list = flatten_list_of_strings(args)

      if list.nil? || list.empty?
        bot.blacklist = []
      else
        bot.blacklist += list
      end
    end

    #
    # return a list of users following the bot. This passes directly
    # to the underlying Twitter API call
    # @see http://rdoc.info/gems/twitter/Twitter/API/FriendsAndFollowers#followers-instance_method
    #
    def followers(opts={})
      bot.followers(opts)
    end
    
    #
    # specify list of strings we will check when deciding to respond
    # to a tweet or not. accepts an array or a comma-delimited string.
    # when called, any subsequent calls to search or replies will
    # filter out tweets with these strings
    #
    # @param [Array, String] args list of usernames
    # @example
    #   exclude "spam, junk, something"
    def exclude(*args)
      e = flatten_list_of_strings(args)
      if e.nil? || e.empty?
        bot.exclude = []
      else
        bot.exclude += e
      end
    end

    
    #
    # The ID of the most recent tweet processed by the bot
    #
    def since_id(s=nil)
      if s
        bot.config[:since_id] = s
      end
      bot.config[:since_id]
    end

    def consumer_secret(s)
      bot.config[:consumer_secret] = s
    end

    def consumer_key(k)
      bot.config[:consumer_key] = k
    end

    def secret(s)
      bot.config[:secret] = s
    end
    def token(s)
      bot.config[:token] = s
    end

    def since_id_reply
      bot.config[:since_id_reply]
    end

    #
    # explicitly save the configuration/state of the bot.
    #
    def update_config
      bot.update_config
    end

    #
    # return the bot's current database connection, if available.
    # handy if you need to manage data with your bot
    #
    def db
      bot.db
    end

    
    protected
    
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
    
  end
end

include Chatterbot::DSL
include Chatterbot::Helpers
