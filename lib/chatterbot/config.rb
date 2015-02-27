module Chatterbot

  #
  # routines for storing config information for the bot
  module Config  
    attr_accessor :config

    MAX_TWEET_ID = 9223372036854775807
    COMMAND_LINE_VARIABLES = [:debug_mode, :no_update, :verbose, :reset_since_id]

    #
    # the entire config for the bot, loaded from YAML files and the DB if applicable
    def config
      @config ||= load_config
    end   

    #
    # has the config been loaded yet?
    def has_config?
      ! @config.nil?
    end   

    #
    # should we log tweets to the database?
    def log_tweets?
      config.has_key?(:db_uri)
    end

    #
    # Check to see if Sequel was loaded successfully.  If not, we won't make any DB calls
    def has_sequel?
      ! defined?(Sequel).nil?
    end
    
    #
    # do we have a DB connection string?
    def has_db?
      has_sequel? && config.has_key?(:db_uri)
    end

    def debug_mode=(d)
      config[:debug_mode] = d
    end

    def no_update=(d)
      config[:no_update] = d
    end

    #
    # should we reset the since_id for this bot?
    # 
    def reset_bot?
      config[:reset_since_id] || false
    end
    
    #
    # are we in debug mode?
    def debug_mode?
      config[:debug_mode] || false
    end

    #
    # Should we run any config updates?
    def update_config?
      config.has_key?(:no_update) ? ! config[:no_update] : true
    end

    #
    # should we write to a log file?
    def logging?
      has_config? && config.has_key?(:log_dest)
    end

    def verbose=(v)
      config[:verbose] = v
    end
   
    def verbose?
      config[:verbose] || false
    end
   
    #
    # destination for log entries
    def log_dest
      config[:log_dest]
    end

    #
    # store since_id to a different key so that it doesn't actually
    # get updated until the bot is done running
    def since_id=(x)
      config[:tmp_since_id] = x
    end

    #
    # return the ID of the most recent tweet pulled up in searches
    def since_id
      config[:since_id] || 1
    end

    #
    # store since_id_reply to a different key so that it doesn't actually
    # get updated until the bot is done running
    def since_id_reply=(x)
      config[:tmp_since_id_reply] = x
    end

    #
    # return the ID of the most recent tweet pulled up in mentions or since_id if since_id_reply is nil
    def since_id_reply
      config[:since_id_reply] || since_id
    end

    #
    # write out our config file
    def update_config
      return if ! update_config?

      # don't update flat file if we can store to the DB instead
      if has_db?
        debug "storing config to database -- you don't need local file anymore"
        store_database_config
      else
        store_local_config
      end
    end

    def update_config_at_exit
      update_config
    end

    def max_id_from(s)
      # don't use max_id if it's this ridiculous number
      # @see https://dev.twitter.com/issues/1300
      sorted = s.reject { |t| !t || t.id == MAX_TWEET_ID }.max { |a, b| a.id <=> b.id }
      sorted && sorted.id
    end

    #
    # update the since_id_reply with the id of the given tweet,
    # unless it is lower thant what we have already
    #
    def update_since_id_reply(tweet)
      return if tweet.nil? or tweet.class != Twitter::Tweet || tweet.id == MAX_TWEET_ID

      tmp_id = tweet.id

      config[:tmp_since_id_reply] = [config[:tmp_since_id_reply].to_i, tmp_id].max
    end
    
    #
    # update the since_id with either the highest ID of the specified
    # tweets, unless it is lower than what we have already
    def update_since_id(search)
      return if search.nil?
     
      tmp_id = if search.is_a?(Twitter::SearchResults)
                 search.attrs[:search_metadata][:max_id]
               elsif search.respond_to?(:max)
                 max_id_from(search)
               elsif search.is_a?(Twitter::Tweet)
                 search.id
               else
                 search
               end.to_i
      
      config[:tmp_since_id] = [config[:tmp_since_id].to_i, tmp_id].max
    end

    #
    # return a hash of the params we need to connect to the Twitter API
    def client_params
      { 
        :consumer_key => config[:consumer_key],
        :consumer_secret => config[:consumer_secret],
        :token => config[:token].nil? ? nil : config[:token],
        :secret => config[:secret].nil? ? nil : config[:secret]
      }
    end

    #
    # do we have an API key specified?
    def needs_api_key?
      config[:consumer_key].nil? || config[:consumer_secret].nil?
    end

    #
    # has this script validated with Twitter OAuth?
    def needs_auth_token?
      config[:token].nil?
    end

    #
    # determine if we're being called by one of our internal scripts
    #
    def chatterbot_helper?
      Chatterbot::from_helper == true
    end
    
    #
    # if we are called by a bot, we want to use the directory of that
    # script.  If we are called by chatterbot-register or another
    # helper script, we want to use the current working directory   
    #
    def working_dir
      if chatterbot_helper?
        Dir.getwd
      else
        File.dirname($0)
        #Dir.pwd
      end
    end
    
    #
    # figure out what config file to load based on the name of the bot
    def config_file
      dest = working_dir
      File.join(File.expand_path(dest), "#{botname}.yml")
    end

    #
    # load in a config file
    def slurp_file(f)
      f = File.expand_path(f)
      tmp = {}

      if File.exist?(f)
        File.open( f ) { |yf| 
          tmp = YAML::load( yf ) 
        }
      end
      tmp.symbolize_keys! unless tmp == false
    end

    #
    # our list of "global config files"
    def global_config_files
      [
       # a system-wide global path
       "/etc/chatterbot.yml",
       
       # a file specified in ENV
       ENV["chatterbot_config"],
       
       # 'global' config file local to the path of the ruby script
       File.join(working_dir, "global.yml")
      ].compact
    end

    #
    # get any config from our global config files
    def global_config
      tmp = {}
      global_config_files.each { |f|
        tmp.merge!(slurp_file(f) || {})      
      }
      tmp
    end

    #
    # bot-specific config settings
    def bot_config
      {
        :consumer_key => ENV["chatterbot_consumer_key"],
        :consumer_secret => ENV["chatterbot_consumer_secret"],
        :token => ENV["chatterbot_token"],
        :secret => ENV["chatterbot_secret"]
      }.delete_if { |k, v| v.nil? }.merge(slurp_file(config_file) || {})
    end

    #
    # load the config settings from the db, if possible
    def db_config
      return {} if db.nil?
      db[:config][:id => botname]
    end
    
    #
    # figure out what we should save to the local config file.  we don't
    # save anything that exists in the global config, unless it's been modified
    # for this particular bot.
    def config_to_save
      # remove keys that are duped in the global config
      tmp = config.delete_if { |k, v| global_config.has_key?(k) && global_config[k] == config[k] }

      # let's not store these, they're just command-line options
      COMMAND_LINE_VARIABLES.each { |k|
        tmp.delete(k)
      }
      
      # update the since_id now
      tmp[:since_id] = tmp.delete(:tmp_since_id) unless ! tmp.has_key?(:tmp_since_id)
      tmp[:since_id_reply] = tmp.delete(:tmp_since_id_reply) unless ! tmp.has_key?(:tmp_since_id_reply)

      tmp
    end
    
    #
    # load in the config from the assortment of places it can be specified.
    def load_config(params={})
      # load the flat-files first
      @config  = global_config.merge(bot_config)
      @config[:db_uri] ||= ENV["chatterbot_db"] unless ENV["chatterbot_db"].nil?

      # if we have a key to load from the DB, do that now
      if @config.has_key?(:db_uri) && @config[:db_uri]
        tmp = db_config
        @config = @config.merge(tmp) unless tmp.nil?
      end
      @config.merge(params)
    end

    #
    # write out the config file for this bot
    def store_local_config
      File.open(config_file, 'w') { |f| YAML.dump(config_to_save, f) }
    end

    #
    # store config settings in the database, if possible
    def store_database_config
      return false if db.nil?

      configs = db[:config]
      data = {
        :since_id => config.has_key?(:tmp_since_id) ? config[:tmp_since_id] : config[:since_id],
        :since_id_reply => config.has_key?(:tmp_since_id_reply) ? config[:tmp_since_id_reply] : config[:since_id_reply],
        :token => config[:token],
        :secret => config[:secret],
        :consumer_secret => config[:consumer_secret],
        :consumer_key => config[:consumer_key],
        :updated_at => Time.now #:NOW.sql_function
      }

      row = configs.filter('id = ?', botname)

      if row.count > 0
        row.update(data)
      else
        data[:id] = botname
        data[:created_at] = Time.now #:NOW.sql_function
        configs.insert data
      end
      
      true
    end

  end
end
