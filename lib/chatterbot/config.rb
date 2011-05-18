module Chatterbot

  #
  # routines for storing config information for the bot
  module Config

    attr_accessor :config
    
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
    # do we have a DB connection string?
    def has_db?
      config.has_key?(:db_uri)
    end

    #
    # are we in debug mode?
    def debug_mode?
      config[:debug_mode] || true # TODO change this to false
    end

    def update_config?
      config[:dry_run] || true
    end

    #
    # should we write to a log file?
    def logging?
      has_config? && config.has_key?(:log_dest)
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
      config[:since_id] || 0
    end   

    #
    # write out our config file
    def update_config
      return if ! update_config?

      # don't update flat file if we can store to the DB instead
      if has_db?
        store_database_config
      else
        store_local_config
      end
    end

    #
    # update the since_id with either the highest ID of the specified
    # tweets, unless it is lower than what we have already
    def update_since_id(search)
      unless search.nil?
        self.since_id = [self.since_id, search["max_id"].to_i].max
      end
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
    # figure out what config file to load based on the name of the bot
    def config_file
      "#{botname}.yml"
    end

    #
    # load in a config file
    def slurp_file(f)
      f = File.expand_path(f)
      debug "load config: #{f}"

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
       File.join(File.dirname(File.expand_path($0)), "global.yml")
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
      slurp_file(config_file) || { }
    end

    #
    # config settings that came from the DB
    def db_config
      load_config_from_db || { }
    end

    #
    # load the config settings from the db, if possible
    def load_config_from_db
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

      # update the since_id now
      tmp[:since_id] = tmp.delete(:tmp_since_id) unless ! tmp.has_key?(:tmp_since_id)

      tmp
    end
    
    
    #
    # load in the config from the assortment of places it can be specified.
    def load_config(params={})
      # load the flat-files first
      @config  = global_config.merge(bot_config).merge(params)
      @config[:db_uri] ||= ENV["chatterbot_db"] unless ENV["chatterbot_db"].nil?

      # if we have a key to load from the DB, do that now
      if @config.has_key?(:db_uri) && @config[:db_uri]
        tmp = db_config
        @config = @config.merge(tmp) unless tmp.nil?
      end
      @config
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
        :since_id => config[:since_id],
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
