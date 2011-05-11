require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Config" do
  before(:each) do
    @bot = Chatterbot::Bot.new    
  end
  
  describe "loading" do
    it "loads config when we need a variable" do
      @bot.should_receive(:load_config).and_return({:foo => :bar})
      @bot.config[:foo].should == :bar
    end

    it "loads both global config and local config" do
      @bot.should_receive(:global_config).and_return({:foo => :bar, :a => :b})
      @bot.should_receive(:bot_config).and_return({:foo => :baz, :custom => :value})
      
      @bot.config[:foo].should == :baz
      @bot.config[:a].should == :b
      @bot.config[:custom].should == :value
    end

    it "returns a log dest" do
      @bot.should_receive(:load_config).and_return({:log_dest => :bar})    
      @bot.log_dest.should == :bar
    end

    it "checks for an auth_token" do
      @bot.should_receive(:load_config).and_return({:token => "123"})
      @bot.needs_auth_token?.should == false
    end

    it "checks for an auth_token" do
      @bot.should_receive(:load_config).and_return({})
      @bot.needs_auth_token?.should == true
    end
  end

  describe "update_config" do
    it "doesn't update keys from the global config" do
      @bot.stub!(:global_config).and_return({:foo => :bar, :a => :b})
      @bot.stub!(:bot_config).and_return({:foo => :bar, :custom => :value})      

      @bot.config_to_save.should == { :custom => :value }
    end
    
    it "does update keys from the global config if they've been customized" do
      @bot.stub!(:global_config).and_return({:foo => :bar, :a => :b})
      @bot.stub!(:bot_config).and_return({:foo => :baz, :custom => :value})      

      @bot.config_to_save.should == { :foo => :baz, :custom => :value }
    end

    it "updates since_id" do
      @bot.config[:tmp_since_id] = 100
      @bot.config_to_save.should == {  :since_id => 100 }
    end
    
  end
  
end
