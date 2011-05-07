module Botter
  module Logging
    def debug(s)
      puts "***** #{s}"
    end

    def validate_tables(db)
      # create an items table
      if ! db.tables.include?(:tweets)
        db.create_table :tweets do
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

    def connect_and_validate
      db = Sequel.connect(@config[:log_uri])
      validate_tables(db)
      db
    end

    def db
      @@db ||= connect_and_validate
    end
    
    def log(txt, source=nil)
      # create a dataset from the items table

      return unless log_tweets?

      tweets = db[:tweets]

      data = {:txt => txt, :bot => botname, :created_at => 'NOW()'.lit}
      if source != nil
        data = data.merge(:user => source['from_user'],
                          :source_id => source['id'],
                          :source_tweet => source['text'])
      end

      # populate the table
      tweets.insert(data)
    end

  end
end
