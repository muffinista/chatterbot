require File.join(File.dirname(__FILE__), '..', 'chatterbot')
require 'optparse'

module Chatterbot
  #
  # very basic DSL to handle the common stuff you would want to do with a bot.
  module DSL
    #
    # @return initialized Twitter::REST::Client
    def client
      bot.client
    end
    
    #
    # search twitter for the specified terms, then pass any matches to
    # the block.
    # @param opts [Hash] options. these will be passed directly to
    # Twitter via the twitter gem. You can see the possible arguments
    # at http://www.rubydoc.info/gems/twitter/Twitter/REST/Search#search-instance_method
    # There is one extra argument:
    # @option options [Integer] :limit limit the number of tweets to
    # return per search

    # @example
    #   search("chatterbot is cool!") do |tweet|
    #     puts tweet.text # this is the actual tweeted text
    #     reply "I agree!", tweet
    #   end
    def search(query, opts = {}, &block)
      bot.search(query, opts, &block)
    end

    #
    # handle tweets that are on the bot's home timeline. this includes
    # tweets from accounts the bot is following, as well as its own tweets
    #
    # @example
    #   home_timeline do |tweet|
    #     puts tweet.text # this is the actual tweeted text
    #     favorite tweet # i like to fave tweets
    #   end
    def home_timeline(opts = {}, &block)
      bot.home_timeline(opts, &block)
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

    def streaming(opts = {}, &block)
      params = {
        :endpoint => :user
      }.merge(opts)

      h = StreamingHandler.new(bot, params)
      h.apply block

      bot.do_streaming(h)
    end
    
    def streaming_tweets(opts={}, &block)
      bot.streaming_tweets(opts, &block)
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
    # @param [id] id A tweet or the ID of a tweet
    def retweet(id)
      bot.retweet(id)
    end


    #
    # favorite a tweet
    # @param [id] id A tweet or the ID of a tweet
    def favorite(id)
      bot.favorite(id)
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
    # handle getting/setting the profile text.
    # @param [p] p The new value for the profile. If this isn't passed in, the method will simply return the current value
    # @return profile text
    def profile_text(p=nil)
      if p.nil?
        bot.profile_text
      else
        bot.profile_text(p)
      end
    end

    #
    # handle getting/setting the profile website
    # @param [p] p The new value for the website. If this isn't passed in, the method will simply return the current value
    # @return profile website
    def profile_website(w=nil)
      if w.nil?
        bot.profile_website
      else
        bot.profile_website(w)
      end
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

      #:nocov:
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
      opts.on('--profile [ARG]', "get/set your bot's profile text") { |p| 
        @handle_profile_text = true
        @profile_text = p
      }
      opts.on('--website [ARG]', "get/set your bot's profile URL") { |u| 
        @handle_profile_website = true
        @profile_website = u
      }

      
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end

      opts.parse!(ARGV)
      #:nocov:

      @bot = Chatterbot::Bot.new(params)

      if @handle_profile_text == true
        if !@profile_text.nil?
          @bot.profile_text @profile_text
        else
          puts @bot.profile_text
        end
      end

      if @handle_profile_website == true
        if !@profile_website.nil?
          @bot.profile_website @profile_website
        else
          puts @bot.profile_website
        end
      end

      if @handle_profile_website == true || @handle_profile_text == true
        exit
      end

      @bot
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
    # specify a bot-specific whitelist of users.  accepts an array, or a
    # comma-delimited string. when called, any subsequent calls to
    # search or replies will only act upon these users.
    #
    # @param [Array, String] args list of usernames or Twitter::User objects
    # @example
    #   whitelist "mean_user, private_user"
    #
    def whitelist(*args)
      list = flatten_list_of_strings(args)

      if list.nil? || list.empty?
        bot.whitelist = []
      else
        bot.whitelist += list
      end
    end

    def only_interact_with_followers
      whitelist followers
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
    # follow a user
    #
    # @param u a Twitter::User or user id
    def follow(u)
      bot.follow(u)
    end

    
    #
    # a common list of bad words, which you might want to filter out.
    # lifted from https://github.com/dariusk/wordfilter/blob/master/lib/badwords.json
    #
    def bad_words
      ["skank", "wetback", "bitch", "cunt", "dick", "douchebag", "dyke", "fag", "nigger", "tranny", "trannies",
       "paki", "pussy", "retard", "slut", "titt", "tits", "wop", "whore", "chink", "fatass", "shemale", "daygo",
       "dego", "dago", "gook", "kike", "kraut", "spic", "twat", "lesbo", "homo", "fatso", "lardass", "jap",
       "biatch", "tard", "gimp", "gyp", "chinaman", "chinamen", "golliwog", "crip", "raghead" ]     
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

    #
    # set the consumer secret
    # @param s [String] the consumer secret
    def consumer_secret(s)
      bot.config[:consumer_secret] = s
    end

    #
    # set the consumer key
    # @param k [String] the consumer key
    def consumer_key(k)
      bot.config[:consumer_key] = k
    end

    #
    # set the secret
    # @param s [String] the secret
    def secret(s)
      bot.config[:secret] = s
    end

    #
    # set the token
    # @param s [String] the token
    def token(s)
      bot.config[:token] = s
    end

    #
    # get the id of the last tweet the bot replied to
    # @return tweet id
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
