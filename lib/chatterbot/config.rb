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

    class << self
      #
      # simple boolean attribute generator. define the attribute and a
      # default value and you get a setter and predicate method
      #
      # @param [Symbol] key the key for the variable
      # @param [Boolean] default default value
      def attr_boolean(key, default=false)
			  class_eval <<-EVAL
          attr_writer :#{key.to_s}

          def #{key.to_s}?
            (@#{key.to_s} == true) || #{default}
          end
        EVAL
      end

      #
      # generate a set of methods to manage checks around the
      # assortment of since_id values we use to track most recent data
      # retrieve from twitter
      #
      # @param [Symbol] key the key for the variable
      def attr_since_id(key = nil)
        attr_name = key.nil? ? "since_id" : ["since_id", key.to_s].join("_")
			  class_eval <<-EVAL
          def #{attr_name}=(x)
            config[:#{attr_name}] = x
          end
          def #{attr_name}
            config[:#{attr_name}] || 1
          end

          def update_#{attr_name}(input)
            max = max_id_from(input)
            config[:#{attr_name}] = [config[:#{attr_name}].to_i, max.to_i].max
          end
        EVAL
      end  
    end

    
    attr_boolean :debug_mode, false
    attr_boolean :verbose, false
    attr_boolean :streaming, false
    attr_boolean :skip_run, false
    attr_boolean :only_interact_with_followers, false    

    attr_since_id
    attr_since_id :home_timeline
    attr_since_id :reply
    attr_since_id :dm

    #
    # should we update our config values?
    # @param [Boolean] val true/false
    def no_update=(val)
      config.no_update = val
    end

    # should we update our config values?
    def no_update?
      config.no_update || false
    end
    
    #
    # return a hash of the params we need to connect to the Twitter API
    def client_params
      { 
        :consumer_key => config[:consumer_key],
        :consumer_secret => config[:consumer_secret],
        :access_token => config[:access_token],
        :access_token_secret => config[:access_token_secret]
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
      config[:access_token].nil?
    end

    
    #
    # Should we run any config updates?
    def update_config?
      !no_update?
    end

    #
    # should we write to a log file?
    def logging?
      config[:log_dest] != nil
    end
   
    #
    # destination for log entries
    def log_dest
      config[:log_dest]
    end

    #
    # given an array or object, return the highest id we can find
    # @param [Enumerable] s the array to check
    #
    def max_id_from(s)
      if ! s.respond_to?(:max)
        if s.respond_to?(:id)
          return s.id
        else
          return s
        end       
      end
     
      
      sorted = s.max { |a, b| a.id.to_i <=> b.id.to_i }
      sorted && sorted.id
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
        :access_token => ENV["chatterbot_access_token"],
        :access_token_secret => ENV["chatterbot_access_secret"] || ENV["chatterbot_access_token_secret"]
      }.delete_if { |k, v| v.nil? }.merge(slurp_file(config_file) || {})
    end
    
    
    #
    # load in the config from the assortment of places it can be specified.
    def load_config(params={})
      read_only_data  = global_config.merge(bot_config).merge(params)
      @config = Chatterbot::ConfigManager.new(config_file, read_only_data)
    end
  end
end
