module Chatterbot
  module DB
    def db
      @_db ||= connect_and_validate
    end

    protected  
    def get_connection
      Sequel.connect(config[:db_uri])
    end
    
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

          String :secret
          String :token
          String :consumer_secret
          String :consumer_key
          
          DateTime :created_at
          DateTime :updated_at
        end
      end
    end

  end
end
