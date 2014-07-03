require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'tempfile'

describe "Chatterbot::Logging" do
  describe "debug logging" do
    before(:each) do
      @bot = Chatterbot::Bot.new
      @logger = double(Logger)
      allow(@bot).to receive(:logger).and_return(@logger)
    end

    it "should call logger on debug" do
      expect(@bot).to receive(:logging?).and_return(true)
      expect(@logger).to receive(:debug).with("rspec hi!")
      @bot.debug "hi!"
    end

    it "should not call logger when not logging desired" do
      expect(@bot).to receive(:logging?).and_return(false)
      expect(@logger).not_to receive(:debug)
      @bot.debug "hi!"
    end

    it "should call logger and also print output when critical" do
      expect(@bot).to receive(:logging?).and_return(true)
      expect(@logger).to receive(:debug).with("rspec hi!")      
      expect(@bot).to receive(:puts).with("hi!")
      @bot.critical "hi!"
    end
  end
  
  describe "#log to database" do
    before(:each) do
      @db_tmp = Tempfile.new("config.db")
      @db_uri = "sqlite://#{@db_tmp.path}"

      @bot = Chatterbot::Bot.new    
      @bot.config[:db_uri] = @db_uri

      expect(@bot).to receive(:log_tweets?).and_return(true)

      expect(@bot).to receive(:botname).and_return("logger")
      allow(Time).to receive(:now).and_return(123)                

      @tweets_table = double(Object)     
      allow(@bot).to receive(:db).and_return({ 
                                   :tweets => @tweets_table
                                 })   
    end
    
    it "logs tweets to the db" do
      expect(@tweets_table).to receive(:insert).with({ :txt => "TEST", :bot => "logger", :created_at => 123})
      @bot.log "TEST"
    end

    it "logs tweets with some source info to the db" do
      source_tweet = Twitter::Tweet.new({:id => 12345, :text => "i should trigger a bot", :user => {:screen_name => "replytome", :id => 456}})

      params = {:txt=>"TEST", :bot=>"logger", :created_at=>123, :user=>"replytome", :source_id=>12345, :source_tweet=>"i should trigger a bot"}      
      
      expect(@tweets_table).to receive(:insert).with(params)
     
      @bot.log "TEST", source_tweet
    end
  end
end
