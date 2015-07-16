module Chatterbot
  require 'yaml/store'

  class ConfigManager
    READ_ONLY_VARIABLES = [:consumer_key, :consumer_secret, :access_token, :access_token_secret, :log_dest]
    attr_accessor :no_update

    def initialize(dest, read_only={}, no_update=false)
      @read_only = read_only
      @store = YAML::Store.new(dest, true)
      @no_update = no_update
    end

    def delete(key)
      return if @no_update == true
      @store.transaction do
        @store.delete(key)
      end
    end
    
    def []=(key, value)
      return if @no_update == true
      @store.transaction do
        @store[key] = value
      end
    end

    def [](key)
      if READ_ONLY_VARIABLES.include?(key)
        return @read_only[key]
      end
      @store.transaction do
        @store[key]
      end
    end
  end
end

