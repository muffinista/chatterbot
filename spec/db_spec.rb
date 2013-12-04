require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

#require 'sequel'

describe "Chatterbot::DB" do
  before(:each) do
    @db_uri = "sqlite:/tmp/chatterbot.db"
    File.delete("/tmp/chatterbot.db") if File.exist?("/tmp/chatterbot.db")
  end

  context "prerequisites" do
    describe "get_connection" do
      it "should make sure sequel is actually installed" do
        Chatterbot::Bot.any_instance.stub(:has_sequel?) { false }
        @bot = Chatterbot::Bot.new
        @bot.config[:db_uri] = @db_uri
        @bot.should_receive(:display_db_config_notice)
        @bot.db
      end
    end
  end

  context "db interactions" do
    before(:each) do
      @bot = Chatterbot::Bot.new
      @bot.stub(:update_config_at_exit)
      @bot.config[:db_uri] = @db_uri
    end

    after(:each) do
      @bot.db.disconnect unless @bot.db.nil?
    end
  
    describe "table creation" do
      [:blacklist, :tweets, :config].each do |table|
        it "should create table #{table}" do
          @tmp_conn = @bot.db
          @tmp_conn.tables.include?(table).should == true
        end
      end      
    end
    
    describe "store_database_config" do
      it "doesn't fail" do
        @bot = Chatterbot::Bot.new    
        @bot.config[:db_uri] = @db_uri
        
        @bot.db
        @bot.store_database_config.should == true
      end
    end
  end
end
