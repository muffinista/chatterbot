module Chatterbot
  require 'yaml/store'

  #
  # wrap YAML::Store to maintain config but have a few read-only
  # variables which we will never set/override
  #
  class ConfigManager

    # list of vars that shouldn't ever be written
    READ_ONLY_VARIABLES = [:consumer_key, :consumer_secret, :access_token, :access_token_secret, :log_dest]

    # if true, we will never actually update the config file
    attr_accessor :no_update

    def initialize(dest, read_only={}, no_update=false)
      @read_only = read_only
      @store = YAML::Store.new(dest, true)
      @no_update = no_update
    end

    # delete a key from the config
    def delete(key)
      return if @no_update == true
      @store.transaction do
        @store.delete(key)
      end
    end

    def to_h
      @store.transaction do
        Hash[@store.roots.map { |k| [k, @store[k]] }]
      end
    end

    # set/update a key
    def []=(key, value)
      return if @no_update == true
      @store.transaction do
        @store[key] = value
      end
    end

    # retrieve a key
    def [](key)
      if READ_ONLY_VARIABLES.include?(key) && @read_only[key]
        return @read_only[key]
      end
      @store.transaction do
        @store[key]
      end
    end
  end
end

