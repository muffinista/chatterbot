require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'tempfile'

describe "Chatterbot::Config" do
  before(:each) do
    @bot = Chatterbot::Bot.new
    @tmp_config_dest = "/tmp/bot.yml"
    allow(@bot).to receive(:config_file).and_return(@tmp_config_dest)
  end
  after(:each) do
    if File.exist?(@tmp_config_dest)
      File.unlink(@tmp_config_dest)
    end
  end
  
  describe "loading" do
    it "loads config when we need a variable" do
      expect(@bot).to receive(:load_config).and_return({:foo => :bar})
      @bot.config = nil

      expect(@bot.config[:foo]).to eq(:bar)
    end

    context "environment variables" do
      before(:each) do
        ENV["chatterbot_consumer_key"] = "env_chatterbot_consumer_key"
        ENV["chatterbot_consumer_secret"] = "env_chatterbot_consumer_secret"
        ENV["chatterbot_access_token"] = "env_chatterbot_token"
        ENV["chatterbot_access_secret"] = "env_chatterbot_secret"
      end

      after(:each) do
        ENV.delete "chatterbot_consumer_key"
        ENV.delete "chatterbot_consumer_secret"
        ENV.delete "chatterbot_access_token"
        ENV.delete "chatterbot_access_secret"
      end

      it "checks for environment variables" do
        @bot.config = nil
        @bot.load_config
        
        expect(@bot.config[:consumer_key]).to eq("env_chatterbot_consumer_key")
        expect(@bot.config[:consumer_secret]).to eq("env_chatterbot_consumer_secret")
        expect(@bot.config[:access_token]).to eq("env_chatterbot_token")
        expect(@bot.config[:access_token_secret]).to eq("env_chatterbot_secret")
      end

      it "works if env var is nil" do
        ENV["chatterbot_consumer_key"] = nil
        @bot.config = nil
        allow(@bot).to receive(:slurp_file).and_return({:consumer_key => "foo"})

        expect(@bot.config[:consumer_key]).to eq("foo")
      end
    end

    it "update_config? is true by default" do
      expect(@bot.update_config?).to eq(true)
    end

    it "update_config? is false if this is a dry run" do
      @bot.no_update = true
      expect(@bot.update_config?).to eq(false)
    end

    
    it "returns a log dest" do
      expect(@bot).to receive(:load_config).and_return({:log_dest => :bar})    
      @bot.config = nil

      expect(@bot.log_dest).to eq(:bar)
    end

    it "checks for an auth_token" do
      expect(@bot).to receive(:load_config).and_return({:access_token => "123"})
      @bot.config = nil

      expect(@bot.needs_auth_token?).to eq(false)
    end

    it "checks for an auth_token" do
      expect(@bot).to receive(:load_config).and_return({})
      @bot.config = nil

      expect(@bot.needs_auth_token?).to eq(true)
    end


    it "checks for an API key" do
      expect(@bot).to receive(:load_config).and_return({})
      @bot.config = nil

      expect(@bot.needs_api_key?).to eq(true)

      @bot.config = {:consumer_key => "ck", :consumer_secret => "cs" }
      expect(@bot.needs_api_key?).to eq(false)
    end
  end

  describe "debug_mode=" do
    it "works" do
      @bot.debug_mode = true
      expect(@bot.debug_mode?).to eq(true)
    end
  end

  describe "no_update=" do
    it "works" do
      @bot.no_update = true
      expect(@bot.no_update?).to eq(true)
    end
  end

  describe "verbose=" do
    it "works" do
      expect(@bot.verbose?).to eq(false)
      @bot.verbose = true
      expect(@bot.verbose?).to eq(true)
    end
  end
    
  describe "debug_mode?" do
    it "works when debug_mode isn't set" do
      expect(@bot.debug_mode?).to eq(false)
    end

    it "works when debug_mode is set" do
      @bot.debug_mode = false
      expect(@bot.debug_mode?).to eq(false)

      @bot.debug_mode = true
      expect(@bot.debug_mode?).to eq(true)
    end
  end

  describe "since_id_reply=" do
    it "works" do

      @bot.since_id_reply = 123
      expect(@bot.config[:since_id_reply]).to eq(123)
    end
  end

  describe "update_since_id_reply" do
    it "works with tweets" do
      @bot.config[:since_id_reply] = 100

      data = fake_tweet(1000, 1000)
      @bot.update_since_id_reply(data)
      expect(@bot.config[:since_id_reply]).to eq(1000)
    end

    it "never rolls back" do
      @bot.config[:since_id_reply] = 100
      data = fake_tweet(50, 50)
      @bot.update_since_id(data)
      expect(@bot.config[:since_id_reply]).to eq(100)
    end
  end

  describe "since_id=" do
    it "works" do
      @bot.since_id = 123
      expect(@bot.config[:since_id]).to eq(123)
    end
  end

  describe "update_since_id" do
    it "works with searches" do
      data = fake_search(1000, 1).search

      @bot.config[:since_id] = 100
      @bot.update_since_id(data)
      expect(@bot.config[:since_id]).to eq(1000)
    end
    
    it "works with tweets" do
      @bot.config[:since_id] = 100

      data = fake_tweet(1000, 1000)
      @bot.update_since_id(data)
      expect(@bot.config[:since_id]).to eq(1000)
    end

    it "works with arrays" do
      @bot.config[:since_id] = 100

      data = [
              fake_tweet(500, 1000),
              fake_tweet(1000, 1000),
              fake_tweet(400, 1000)
             ]
              
      @bot.update_since_id(data)
      expect(@bot.config[:since_id]).to eq(1000)
    end

    it "works with an id" do
      @bot.config[:since_id] = 100
              
      @bot.update_since_id(1000)
      expect(@bot.config[:since_id]).to eq(1000)
    end
    
    it "never rolls back" do
      @bot.config[:since_id] = 100
      data = fake_tweet(50, 50)
      @bot.update_since_id(data)
      expect(@bot.config[:since_id]).to eq(100)     
    end
  end
  

  
  describe "global config files" do
    it "has an array of global_config_files" do
      ENV["chatterbot_config"] = "/tmp/foo.yml"
      expect(@bot.global_config_files.first).to eq("/etc/chatterbot.yml")
      expect(@bot.global_config_files[1]).to eq("/tmp/foo.yml")
      expect(@bot.global_config_files.last).to include("/global.yml")
    end

    it "slurps in all the global_config_files" do
      allow(@bot).to receive(:global_config_files).and_return(["config.yml", "config2.yml", "config3.yml"])
      expect(@bot).to receive(:slurp_file).with("config.yml").and_return({:a => 1 })
      expect(@bot).to receive(:slurp_file).with("config2.yml").and_return({:b => 2 })
      expect(@bot).to receive(:slurp_file).with("config3.yml").and_return({:c => 3 })      

      expect(@bot.global_config).to eq({ :a => 1, :b => 2, :c => 3})
    end

    it "priorities last file in list" do
      allow(@bot).to receive(:global_config_files).and_return(["config.yml", "config2.yml", "config3.yml"])
      expect(@bot).to receive(:slurp_file).with("config.yml").and_return({:a => 1 })
      expect(@bot).to receive(:slurp_file).with("config2.yml").and_return({:b => 2 })
      expect(@bot).to receive(:slurp_file).with("config3.yml").and_return({:a => 100, :b => 50, :c => 3 })      
      expect(@bot.global_config).to eq({ :a => 100, :b => 50, :c => 3})
    end
  end

  
  describe "working_dir" do
    it "returns getwd for chatterbot scripts" do
      expect(@bot).to receive(:chatterbot_helper?).and_return(true)
      expect(@bot.working_dir).to eq(Dir.getwd)
    end

    it "returns calling dir for non-chatterbot scripts" do
      expect(@bot).to receive(:chatterbot_helper?).and_return(false)
      expect(@bot.working_dir).to eq(File.dirname($0))
    end
  end
  
  describe "file I/O" do
    it "loads in some YAML" do
      tmp = {:since_id => 0}
      
      src = Tempfile.new("config")
      src << tmp.to_yaml
      src.flush
      
      expect(@bot.slurp_file(src.path)).to eq(tmp)
    end

    it "symbolizes keys" do
      tmp = {'since_id' => 0}
      
      src = Tempfile.new("config")
      src << tmp.to_yaml
      src.flush
      
      expect(@bot.slurp_file(src.path)).to eq({ :since_id => 0 })
    end
  end

end
