require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Blacklist" do
  it "loads the global blacklist from the db" do

  end

  it "has a bot-specific blacklist" do

  end
  
  it "has a list of excluded phrases" do
    @bot = test_bot
    @bot.exclude = ["junk", "i hate bots", "foobar", "spam"]
    @bot.skip_me?("did you know that i hate bots?").should == true
  end

  it "blacklist includes bot list and global list" do
    bot = test_bot
    bot.should_receive(:bot_blacklist).and_return(["a"])
    bot.should_receive(:load_global_blacklist).and_return(["b", "c"]) 
    
    bot.blacklist.should == ["a", "b", "c"]      
  end

  describe "skip_me?" do
    before(:each) do
      @bot = test_bot
      @bot.stub!(:exclude).and_return(["junk", "i hate bots", "foobar", "spam"])
    end

    it "blocks tweets with phrases we don't want" do
      @bot.skip_me?("did you know that i hate bots?").should == true
    end

    it "allows users we do want" do
      @bot.skip_me?("a tweet without any bad content").should == false
    end

    it "works with result hashes" do
      @bot.skip_me?({"text" => "did you know that i hate bots?"}).should == true
      @bot.skip_me?({"text" => "a tweet without any bad content"}).should == false
    end
  end

  describe "on_blacklist?" do
    before(:each) do
      @bot = test_bot
      @bot.stub!(:load_global_blacklist).and_return(["skippy", "blippy", "dippy"])
    end

    it "blocks users we don't want" do
      @bot.on_blacklist?("skippy").should == true
    end

    it "allows users we do want" do
      @bot.on_blacklist?("flippy").should == false
    end

    it "works with result hashes" do
      @bot.on_blacklist?({"from_user" => "skippy"}).should == true
      @bot.on_blacklist?({"from_user" => "flippy"}).should == false
    end
    
  end
end
