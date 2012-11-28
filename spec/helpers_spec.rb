require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Helpers" do
  it "#tweet_user works with [:from_user]" do
    bot = Chatterbot::Bot.new
    bot.tweet_user({:from_user => "foo"}).should == "@foo"
    bot.tweet_user({:from_user => "@foo"}).should == "@foo"    
  end

  it "#tweet_user works with [:user][:screen_name]" do
    bot = Chatterbot::Bot.new
    bot.tweet_user({:user => {:screen_name => "foo"}}).should == "@foo"
    bot.tweet_user({:user => {:screen_name => "@foo"}}).should == "@foo"    
  end
   
  it "#tweet_user works with string" do
    bot = Chatterbot::Bot.new
    bot.tweet_user("foo").should == "@foo"
    bot.tweet_user("@foo").should == "@foo"    
  end

  describe "#from_user" do
    before(:each) do
      @bot = Chatterbot::Bot.new
    end

    it "should accept strings" do
      @bot.from_user("x").should == "x"
    end

    it "should accept :from_user tweet" do
      @bot.from_user(Twitter::Tweet.new(:id => 123, :from_user => "x")).should == "x"
    end

    it "should accept :screen_name" do
      @bot.from_user(:user => {:screen_name => "x"}).should == "x"
    end
  end
  
  describe "#botname" do    
    before(:each) do
      class TestBot < Chatterbot::Bot; end
      @bot = Chatterbot::Bot.new
      #@bot.client = mock(Object)
    end

    it "can set botname" do
      @bot = TestBot.new
      @bot.botname = "foo"
      @bot.botname.should == "foo"
    end
    
    it "calls botname smartly for inherited classes" do
      @bot2 = TestBot.new
      @bot2.botname.should == "testbot"
    end

    it "calls botname for non-inherited bots" do
      File.should_receive(:basename).and_return("bot")
      @bot.botname.should == "bot"
    end

    it "uses specified name" do
      @bot = Chatterbot::Bot.new(:name => 'xyzzy')
      @bot.botname.should == "xyzzy"
    end
  end

  describe "#replace_variables" do
    before(:each) do
      @bot = Chatterbot::Bot.new(:name => 'xyzzy')
      @tweet = {}
    end

    it "should replace username by calling tweet_user" do
      @bot.should_receive(:tweet_user).and_return("@foobar")
      @bot.replace_variables("#USER#", @tweet).should == "@foobar"
    end
    
    it "should be fine with not replacing anything" do
      @bot.replace_variables("foobar", @tweet).should == "foobar"
    end
    
    it "should be fine without a tweet" do
      @bot.replace_variables("foobar").should == "foobar"
    end
  end  
end
