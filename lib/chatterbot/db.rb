module Chatterbot
  module DB
    def create_tweets
      if ! @_db.tables.include?(:tweets)
        @_db.create_table :tweets do
          primary_key :id
          String :txt
          String :bot
          String :user
          String :source_id
          String :source_tweet
          
          DateTime :created_at
        end
      end
    end

    def create_config
      if ! @_db.tables.include?(:config)
        @_db.create_table :config do
          String :id, :primary_key => true

          Bignum :since_id

          String :secret
          String :token
          String :consumer_secret
          String :consumer_key
          
          DateTime :created_at
          DateTime :updated_at
        end
      end
    end

    def connect_and_validate
      @_db ||= Sequel.connect(config[:log_uri])
      create_tweets
      create_config
      @_db
    end

    def db
      @_db ||= connect_and_validate
    end
  end
end
