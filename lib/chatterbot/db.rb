module Chatterbot

  #
  # routines for optionally interacting with a database for logging
  # tweets, and storing config data there. Uses Sequel to handle the
  # heavy lifing.
  module DB
    #
    # connect to the database, and generate any missing tables
    def db
      @_db ||= connect_and_validate
    end

    #:nocov:
    def display_db_config_notice
      puts "ERROR: You have specified a DB connection, but you need to install the sequel gem to use it"
    end
    #:nocov:

    protected

    #
    # get a DB object from Sequel
    def get_connection
      if ! has_sequel? && config.has_key?(:db_uri)
        display_db_config_notice
      elsif has_sequel?
        Sequel.connect(config[:db_uri])
      end
    end

    #
    # try and connect to the DB, and create tables that are missing.
    def connect_and_validate
      conn = get_connection
      return if conn.nil?

      if ! conn.tables.include?(:blacklist)
        conn.create_table :blacklist do
          String :user, :primary_key => true
          DateTime :created_at
        end
      end

      if ! conn.tables.include?(:tweets)
        conn.create_table :tweets do
          primary_key :id
          String :txt
          String :bot
          String :user
          String :source_id
          String :source_tweet

          DateTime :created_at
        end
      end

      if ! conn.tables.include?(:config)
        conn.create_table :config do
          String :id, :primary_key => true

          Bignum :since_id
          Bignum :since_id_reply

          String :secret
          String :token
          String :consumer_secret
          String :consumer_key

          DateTime :created_at
          DateTime :updated_at
        end
      end

      conn
    end

  end
end
