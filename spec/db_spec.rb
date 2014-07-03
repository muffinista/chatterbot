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
        allow_any_instance_of(Chatterbot::Bot).to receive(:has_sequel?) { false }
        @bot = Chatterbot::Bot.new
        @bot.config[:db_uri] = @db_uri
        expect(@bot).to receive(:display_db_config_notice)
        @bot.db
      end
    end
  end

  context "db interactions" do
    before(:each) do
      @bot = Chatterbot::Bot.new
      allow(@bot).to receive(:update_config_at_exit)
      @bot.config[:db_uri] = @db_uri
    end

    after(:each) do
      @bot.db.disconnect unless @bot.db.nil?
    end
  
    describe "table creation" do
      [:blacklist, :tweets, :config].each do |table|
        it "should create table #{table}" do
          @tmp_conn = @bot.db
          expect(@tmp_conn.tables.include?(table)).to eq(true)
        end
      end      
    end
    
    describe "store_database_config" do
      it "doesn't fail" do
        @bot = Chatterbot::Bot.new    
        @bot.config[:db_uri] = @db_uri
        
        @bot.db
        expect(@bot.store_database_config).to eq(true)
      end
    end
  end
end
