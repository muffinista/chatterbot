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
    # NOTE: by default, search terms are wrapped in quotes so the
    # Twitter API will return tweets that include your exact query.
    # You can disable this by passing exact:false as an option
    #
    # @param args [Hash] options. these will be passed directly to
    # Twitter via the twitter gem. You can see the possible arguments
    # at http://www.rubydoc.info/gems/twitter/Twitter/REST/Search#search-instance_method
    #
    # @example
    #   search("chatterbot is cool!") do |tweet|
    #     puts tweet.text # this is the actual tweeted text
    #     reply "I agree!", tweet
    #   end
    def search(*args, &block)
      bot.register_handler(:search, args, &block)
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
    def home_timeline(&block)
      bot.register_handler(:home_timeline, block)
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
      bot.register_handler(:replies, block)
    end

    #
    # handle direct messages sent to the bot. Each time this is called, chatterbot
    # will pass any DMs since the last call to the specified block
    #
    # @example
    #   direct_messages do |dm|
    #     puts dm.text # this is the actual tweeted text
    #     direct_message "Thanks for the mention!", dm.sender
    #   end
    def direct_messages(&block)
      bot.register_handler(:direct_messages, block)
    end
    
    
    #
    # handle notifications of bot tweets favorited by other users.
    # Using this block will require usage of the Streaming API.
    #
    # @example
    #   favorited do |tweet|
    #     puts tweet.text # this is the actual tweeted text
    #     reply "@#{user.screen_name} thanks for the fave!", tweet
    #   end
    def favorited(&block)
      bot.register_handler(:favorited, block)
    end
  
    #
    # handle notifications that the bot has a new follower.
    # Using this block will require usage of the Streaming API.
    #
    # @example
    #   followed do |user|
    #     follow user
    #   end
    def followed(&block)
      bot.register_handler(:followed, block)
    end
  
    #
    # handle notifications of tweets on the bot's timeline that were deleted.
    # Using this block will require usage of the Streaming API.
    def deleted(&block)
      bot.register_handler(:deleted, block)
    end


    #
    # enable or disable usage of the Streaming API
    #
    def use_streaming(s=nil)
      s = true if s.nil?
      bot.streaming = s
    end
    
    
    #
    # send a tweet
    #
    # @param [String] txt the text you want to tweet
    # @param [Hash] params options for the tweet. You can get an idea
    #   of possible values you can send here from the underlying Twitter
    #   gem docs: http://rdoc.info/gems/twitter/Twitter/API#update-instance_method
    # @option params [String,File] :media Optional file object to send
    #   with the tweet. Must be an image or video that will be accepted by
    #   Twitter. You can pass a File object, or the path to a file
    # @see http://rdoc.info/gems/twitter/Twitter/API#update-instance_method
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
    # @param [Hash] params options for the tweet. You can get an idea
    #   of possible values you can send here from the underlying Twitter
    #   gem docs: http://rdoc.info/gems/twitter/Twitter/API#update-instance_method
    # @option params [String,File] :media Optional file object to send with the
    #   tweet. Must be an image or video that will be accepted by
    #   Twitter. You can pass a File object, or the path to a file
    # @see http://rdoc.info/gems/twitter/Twitter/API#update-instance_method
    def reply(txt, source, params={})
      bot.reply(txt, source, params)
    end

    #
    # send a direct message to the specified user
    # 
    # @param [String] txt the text you want to tweet
    # @param [User] user to send the DM to
    def direct_message(txt, user=nil)
      bot.direct_message(txt, user)
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
    # @param [w] w The new value for the website. If this isn't passed in, the method will simply return the current value
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

      @bot_command = nil
      
      #
      # parse any command-line options and use them to initialize the bot
      #
      params = {}

      #:nocov:
      opts = OptionParser.new

      opts.banner = "Usage: #{File.basename($0)} [options]"

      opts.separator ""
      opts.separator "Specific options:"


      opts.on('-c', '--config [ARG]', "Specify a config file to use")    { |c| ENV["chatterbot_config"] = c }
      opts.on('-t', '--test', "Run the bot without actually sending any tweets") { params[:debug_mode] = true }
      opts.on('-v', '--verbose', "verbose output to stdout")    { params[:verbose] = true }
      opts.on('--dry-run', "Run the bot in test mode, and also don't update the database")    { params[:debug_mode] = true ; params[:no_update] = true }

      opts.on('-r', '--reset', "Reset your bot to ignore old tweets") {
        @bot_command = :reset_since_id_counters
      }

      opts.on('--profile [ARG]', "get/set your bot's profile text") { |p| 
        @bot_command = :profile_text
        @bot_command_args = [ p ]
      }

      opts.on('--website [ARG]', "get/set your bot's profile URL") { |u| 
        @bot_command = :profile_website
        @bot_command_args = [ u ]
      }
      
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end

      opts.parse!(ARGV)
      #:nocov:

      @bot = Chatterbot::Bot.new(params)
      if @bot_command != nil
        @bot.skip_run = true
        result = @bot.send(@bot_command, *@bot_command_args)
        puts result
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
    # specify a bot-specific blocklist of users.  accepts an array, or a
    # comma-delimited string. when called, any subsequent calls to
    # search or replies will filter out these users.
    #
    # @param [Array, String] args list of usernames
    # @example
    #   blocklist "mean_user, private_user"
    #
    def blocklist(*args)
      list = flatten_list_of_strings(args)

      if list.nil? || list.empty?
        bot.blocklist = []
      else
        bot.blocklist += list
      end
    end
    alias :blacklist :blocklist

    
    #
    # specify a bot-specific safelist of users.  accepts an array, or a
    # comma-delimited string. when called, any subsequent calls to
    # search or replies will only act upon these users.
    #
    # @param [Array, String] args list of usernames or Twitter::User objects
    # @example
    #   safelist "mean_user, private_user"
    #
    def safelist(*args)
      list = flatten_list_of_strings(args)

      if list.nil? || list.empty?
        bot.safelist = []
      else
        bot.safelist += list
      end
    end
    alias :whitelist :safelist
    
    #
    # specify that the bot should only reply to tweets from users that
    # are followers, basically making interactions opt-in
    #
    def only_interact_with_followers
      bot.config[:only_interact_with_followers] = true
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
      [
        "biatch",
        "bitch",
        "chinaman",
        "chinamen",
        "chink",
        "crip",
        "cunt",
        "dago",
        "daygo",
        "dego",
        "dick",
        "douchebag",
        "dyke",
        "fag",
        "fatass",
        "fatso",
        "gash",
        "gimp",
        "golliwog",
        "gook",
        "gyp",
        "homo",
        "hooker",
        "jap",
        "kike",
        "kraut",
        "lardass",
        "lesbo",
        "negro",
        "nigger",
        "paki",
        "pussy",
        "raghead",
        "retard",
        "shemale",
        "skank",
        "slut",
        "spic",
        "tard",
        "tits",
        "titt",
        "trannies",
        "tranny",
        "twat",
        "wetback",
        "whore",
        "wop"
      ]
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
      bot.deprecated "Setting consumer_secret outside of your config file is deprecated!", Kernel.caller.first
      bot.config[:consumer_secret] = s
    end
    
    #
    # set the consumer key
    # @param k [String] the consumer key
    def consumer_key(k)
      bot.deprecated "Setting consumer_key outside of your config file is deprecated!",  Kernel.caller.first
      bot.config[:consumer_key] = k
    end

    #
    # set the secret
    # @param s [String] the secret
    def secret(s)
      bot.deprecated "Setting access_token_secret outside of your config file is deprecated!", Kernel.caller.first
      bot.config[:access_token_secret] = s
    end

    #
    # set the token
    # @param s [String] the token
    def token(s)
      bot.deprecated "Setting access_token outside of your config file is deprecated!", Kernel.caller.first
      bot.config[:access_token] = s
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
