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
      ! config.nil? && config.has_key?(:log_dest)
    end

    def log_dest
      config[:log_dest]
    end
    
    def since_id=(x)
      config[:since_id] = x
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

    #
    # figure out what config file to load
    #
    def config_file
      filename = "#{File.basename($0,".rb")}.yml"
      debug "load config: #{filename}"
      File.expand_path(filename)
    end

    def load_config
      tmp = {}
      begin
        File.open( config_file ) { |yf| 
          tmp = YAML::load( yf ) 
        }
        tmp.symbolize_keys! if tmp
      rescue Exception => err
#        critical err.message
        tmp = {
          :since_id => 0
        }
      end

      # defaults for now, obviously a big hack.  this is for botly, at:
      # http://dev.twitter.com/apps/207151
      if ! tmp.has_key?(:consumer_key)
        tmp[:consumer_key] = "hjaOOEeeMpJSqZR7dvhxjg"
        tmp[:consumer_secret] = "wA5iqjfCf9aeGMMItqd6ylEEZAbcm7m6R7vVpaQV0s"
      end

      tmp
#      @config = tmp
    end

    # write out our config file
    def update_config #(tmp=config)
      if has_config?
        tmp = config
      
        # update datastore
        if ! @tmp_since_id.nil?
          tmp[:since_id] = @tmp_since_id
        end

        File.foreach(file) { |line|  }.open(config_file, 'w') { |f| YAML.dump(tmp, f) }
      end

    end
  end
end
