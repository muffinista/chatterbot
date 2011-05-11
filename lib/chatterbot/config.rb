module Chatterbot
  module Config

    #    def config=(x)
    #      @config = x
    #    end

    def config
      @_config ||= load_config
    end   

    def has_config?
      ! @_config.nil?
    end   

    def log_tweets?
      config.has_key?(:log_uri)
    end

    def debug_mode?
      true
    end

    def logging?
      has_config? && config.has_key?(:log_dest)
    end

    def log_dest
      config[:log_dest]
    end

    #
    # store since_id to a different key so that it doesn't actually
    # get updated until the bot is done running
    #
    def since_id=(x)
      config[:tmp_since_id] = x
    end
    def since_id
      config[:since_id] || 0
    end   
    
    def update_since_id(search)
      unless search.nil?
        self.since_id = [self.since_id, search["max_id"].to_i].max
      end
    end
        
    def client_params
      { 
        :consumer_key => config[:consumer_key],
        :consumer_secret => config[:consumer_secret],
        :token => config[:token].nil? ? nil : config[:token],
        :secret => config[:secret].nil? ? nil : config[:secret]
      }
    end

    def needs_auth_token?
      config[:token].nil?
    end


    def botname
      File.basename($0,".rb")
    end

    #
    # figure out what config file to load
    #
    def config_file
      "#{botname}.yml"
    end

    def slurp_file(f)
      f = File.expand_path(f)
      debug "load config: #{f}"

      tmp = {}

      if File.exist?(f)
        File.open( f ) { |yf| 
          tmp = YAML::load( yf ) 
          puts tmp.inspect
        }
      end
      tmp.symbolize_keys! unless tmp == false
    end
    
    def global_config
      @_global_config ||= (slurp_file("global.yml") || {})
    end
    def bot_config
      @_bot_config ||= (slurp_file(config_file) || { })
    end

    def config_to_save
      # remove keys that are duped in the global config
      tmp = config.delete_if { |k| global_config.has_key?(k) && global_config[k] == config[k] }

      # update the since_id now
      tmp[:since_id] = tmp.delete(:tmp_since_id) unless ! tmp.has_key?(:tmp_since_id)

      tmp
    end
    
    def load_config
      global_config.merge(bot_config)
    end

    # write out our config file
    def update_config
      File.open(config_file, 'w') { |f| YAML.dump(config_to_save, f) }
      store_database_config
    end

    def store_database_config
      return if db.nil?

      configs = db[:config]
      row = configs.filter('id = ?', botname)

      data = {
        :since_id => config[:since_id],
        :token => config[:token],
        :secret => config[:secret],
        :consumer_secret => config[:consumer_secret],
        :consumer_key => config[:consumer_key],
        :updated_at => :NOW.sql_function
      }

      if row.count > 0
        row.update(data)
      else
        data[:id] = botname
        data[:created_at] =:NOW.sql_function
        configs.insert data
      end
    end

  end
end
