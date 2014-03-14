require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'tempfile'

describe "Chatterbot::Logging" do
  describe "debug logging" do
    before(:each) do
      @bot = Chatterbot::Bot.new
      @logger = double(Logger)
      @bot.stub(:logger).and_return(@logger)
    end

    it "should call logger on debug" do
      @bot.should_receive(:logging?).and_return(true)
      @logger.should_receive(:debug).with("rspec hi!")
      @bot.debug "hi!"
    end

    it "should not call logger when not logging desired" do
      @bot.should_receive(:logging?).and_return(false)
      @logger.should_not_receive(:debug)
      @bot.debug "hi!"
    end

    it "should call logger and also print output when critical" do
      @bot.should_receive(:logging?).and_return(true)
      @logger.should_receive(:debug).with("rspec hi!")      
      @bot.should_receive(:puts).with("hi!")
      @bot.critical "hi!"
    end
  end
  
  describe "#log to database" do
    before(:each) do
      @db_tmp = Tempfile.new("config.db")
      @db_uri = "sqlite://#{@db_tmp.path}"

      @bot = Chatterbot::Bot.new    
      @bot.config[:db_uri] = @db_uri

      @bot.should_receive(:log_tweets?).and_return(true)

      @bot.should_receive(:botname).and_return("logger")
      Time.stub(:now).and_return(123)                

      @tweets_table = double(Object)     
      @bot.stub(:db).and_return({ 
                                   :tweets => @tweets_table
                                 })   
    end
    
    it "logs tweets to the db" do
      @tweets_table.should_receive(:insert).with({ :txt => "TEST", :bot => "logger", :created_at => 123})
      @bot.log "TEST"
    end

    it "logs tweets with some source info to the db" do
      source_tweet = Twitter::Tweet.new({:id => 12345, :text => "i should trigger a bot", :user => {:screen_name => "replytome", :id => 456}})

      params = {:txt=>"TEST", :bot=>"logger", :created_at=>123, :user=>"replytome", :source_id=>12345, :source_tweet=>"i should trigger a bot"}      
      
      @tweets_table.should_receive(:insert).with(params)
     
      @bot.log "TEST", source_tweet
    end
  end
end
