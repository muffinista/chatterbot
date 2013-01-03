require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'tempfile'

describe "Chatterbot::Config" do
  before(:each) do
    @bot = Chatterbot::Bot.new    
  end
  
  describe "loading" do
    it "overrides with incoming params" do
      @bot.should_receive(:global_config).and_return({:foo => :bar})      
      tmp = @bot.load_config({:foo => :baz})
      tmp[:foo].should == :baz
    end
    
    it "loads config when we need a variable" do
      @bot.should_receive(:load_config).and_return({:foo => :bar})
      @bot.config = nil

      @bot.config[:foo].should == :bar
    end

    it "loads both global config and local config" do
      @bot.should_receive(:global_config).and_return({:foo => :bar, :a => :b})
      @bot.should_receive(:bot_config).and_return({:foo => :baz, :custom => :value})

      @bot.config = nil
      
      
      @bot.config[:foo].should == :baz
      @bot.config[:a].should == :b
      @bot.config[:custom].should == :value
    end

    it "update_config? is true by default" do
      @bot.update_config?.should == true
    end

    it "update_config? is false if this is a dry run" do
      @bot.config[:no_update] = true
      @bot.update_config?.should == false
    end

    
    it "returns a log dest" do
      @bot.should_receive(:load_config).and_return({:log_dest => :bar})    
      @bot.config = nil

      @bot.log_dest.should == :bar
    end

    it "checks for an auth_token" do
      @bot.should_receive(:load_config).and_return({:token => "123"})
      @bot.config = nil

      @bot.needs_auth_token?.should == false
    end

    it "checks for an auth_token" do
      @bot.should_receive(:load_config).and_return({})
      @bot.config = nil

      @bot.needs_auth_token?.should == true
    end


    it "checks for an API key" do
      @bot.should_receive(:load_config).and_return({})
      @bot.config = nil

      @bot.needs_api_key?.should == true

      @bot.config = {:consumer_key => "ck", :consumer_secret => "cs" }
      @bot.needs_api_key?.should == false
    end
  end

  describe "debug_mode=" do
    it "works" do
      @bot.debug_mode = true
      @bot.config[:debug_mode].should == true
    end
  end

  describe "no_update=" do
    it "works" do
      @bot.no_update = true
      @bot.config[:no_update].should == true
    end
  end

  describe "verbose=" do
    it "works" do
      @bot.verbose = true
      @bot.config[:verbose].should == true
    end
  end
  
  describe "reset_bot?" do
    it "works when reset_bot isn't set" do
      @bot.reset_bot?.should == false
    end

    it "works when reset_bot is set" do
      @bot.config[:reset_since_id] = false
      @bot.reset_bot?.should == false

      @bot.config[:reset_since_id] = true
      @bot.reset_bot?.should == true
    end
  end

  
  describe "debug_mode?" do
    it "works when debug_mode isn't set" do
      @bot.debug_mode?.should == false
    end

    it "works when debug_mode is set" do
      @bot.config[:debug_mode] = false
      @bot.debug_mode?.should == false

      @bot.config[:debug_mode] = true
      @bot.debug_mode?.should == true
    end
  end

  describe "since_id=" do
    it "works" do
      @bot.since_id = 123
      @bot.config[:tmp_since_id].should == 123
    end
  end
  
  describe "update_since_id" do
    it "works with searches" do
      data = fake_search(1000, 1).search

      @bot.config[:tmp_since_id] = 100
      @bot.update_since_id(data)
      @bot.config[:tmp_since_id].should == 1000
    end

    it "works with tweets" do
      @bot.config[:tmp_since_id] = 100

      data = fake_tweet(1000, 1000, true)
      @bot.update_since_id(data)
      @bot.config[:tmp_since_id].should == 1000
    end

    it "works with arrays" do
      @bot.config[:tmp_since_id] = 100

      data = [
              fake_tweet(500, 1000, true),
              fake_tweet(1000, 1000, true),
              fake_tweet(400, 1000, true)
             ]
              
      @bot.update_since_id(data)
      @bot.config[:tmp_since_id].should == 1000
    end
    
    it "never rolls back" do
      @bot.config[:tmp_since_id] = 100
      data = fake_tweet(50, 50, true)
      @bot.update_since_id(data)
      @bot.config[:tmp_since_id].should == 100     
    end
  end
  
  
  describe "update_config" do
    it "doesn't update the config if update_config? is false" do
      @bot.should_receive(:update_config?).and_return(false)
      @bot.should_not_receive(:has_db?)
      @bot.update_config
    end

    it "doesn't update keys from the global config" do
      @bot.stub!(:global_config).and_return({:foo => :bar, :a => :b})
      @bot.stub!(:bot_config).and_return({:foo => :bar, :custom => :value})      

      @bot.config = nil
      
      @bot.config_to_save.should == { :custom => :value }
    end
    
    it "does update keys from the global config if they've been customized" do
      @bot.stub!(:global_config).and_return({:foo => :bar, :a => :b})
      @bot.stub!(:bot_config).and_return({:foo => :baz, :custom => :value})      

      @bot.config = nil
      
      @bot.config_to_save.should == { :foo => :baz, :custom => :value }
    end

    it "updates since_id" do
      @bot.config[:tmp_since_id] = 100
      @bot.config_to_save[:since_id].should == 100
    end
  end

  
  describe "global config files" do
    it "has an array of global_config_files" do
      ENV["chatterbot_config"] = "/tmp/foo.yml"
      @bot.global_config_files.first.should == "/etc/chatterbot.yml"
      @bot.global_config_files[1].should == "/tmp/foo.yml"
      @bot.global_config_files.last.should include("/global.yml")
    end

    it "slurps in all the global_config_files" do
      @bot.stub(:global_config_files).and_return(["config.yml", "config2.yml", "config3.yml"])
      @bot.should_receive(:slurp_file).with("config.yml").and_return({:a => 1 })
      @bot.should_receive(:slurp_file).with("config2.yml").and_return({:b => 2 })
      @bot.should_receive(:slurp_file).with("config3.yml").and_return({:c => 3 })      

      @bot.global_config.should == { :a => 1, :b => 2, :c => 3}
    end

    it "priorities last file in list" do
      @bot.stub(:global_config_files).and_return(["config.yml", "config2.yml", "config3.yml"])
      @bot.should_receive(:slurp_file).with("config.yml").and_return({:a => 1 })
      @bot.should_receive(:slurp_file).with("config2.yml").and_return({:b => 2 })
      @bot.should_receive(:slurp_file).with("config3.yml").and_return({:a => 100, :b => 50, :c => 3 })      
      @bot.global_config.should == { :a => 100, :b => 50, :c => 3}
    end
  end

  
  describe "working_dir" do
    it "returns getwd for chatterbot scripts" do
      @bot.should_receive(:chatterbot_helper?).and_return(true)
      @bot.working_dir.should == Dir.getwd
    end

    it "returns calling dir for non-chatterbot scripts" do
      @bot.should_receive(:chatterbot_helper?).and_return(false)
      @bot.working_dir.should == File.dirname($0)
    end
  end
  
  describe "file I/O" do
    it "loads in some YAML" do
      tmp = {:since_id => 0}
      
      src = Tempfile.new("config")
      src << tmp.to_yaml
      src.flush
      
      @bot.slurp_file(src.path).should == tmp
    end

    it "symbolizes keys" do
      tmp = {'since_id' => 0}
      
      src = Tempfile.new("config")
      src << tmp.to_yaml
      src.flush
      
      @bot.slurp_file(src.path).should == { :since_id => 0 }
    end
  
    it "doesn't store local file if we can store to db instead" do
      @bot.should_receive(:has_db?).and_return(true)
      @bot.should_receive(:store_database_config)
      @bot.update_config     
    end
  
    it "stores local file if no db" do
      @bot.should_receive(:has_db?).and_return(false)
      @bot.should_not_receive(:store_database_config)
      @bot.should_receive(:store_local_config)      
      @bot.update_config     
    end
  end

  describe "store_local_config" do
    before(:each) do
      tmp = {:x => 123, :foo => :bar}
      
      @src = Tempfile.new("config")

      @bot.stub!(:config_file).and_return(@src.path)
      @bot.stub!(:config_to_save).and_return(tmp)
    end

    it "should work" do
      @bot.store_local_config
      @bot.slurp_file(@src.path).should == { :x => 123, :foo => :bar }
    end
  end
  
end
