require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Helpers" do
  it "#tweet_user works with [:from_user]" do
    bot = Chatterbot::Bot.new
    expect(bot.tweet_user({:from_user => "foo"})).to eq("@foo")
    expect(bot.tweet_user({:from_user => "@foo"})).to eq("@foo")    
  end

  it "#tweet_user works with [:user][:screen_name]" do
    bot = Chatterbot::Bot.new
    expect(bot.tweet_user({:user => {:screen_name => "foo"}})).to eq("@foo")
    expect(bot.tweet_user({:user => {:screen_name => "@foo"}})).to eq("@foo")    
  end
   
  it "#tweet_user works with string" do
    bot = Chatterbot::Bot.new
    expect(bot.tweet_user("foo")).to eq("@foo")
    expect(bot.tweet_user("@foo")).to eq("@foo")    
  end

  describe "#from_user" do
    before(:each) do
      @bot = Chatterbot::Bot.new
    end

    it "should accept strings" do
      expect(@bot.from_user("x")).to eq("x")
    end

    it "should accept tweet" do
      t = Twitter::Tweet.new(:id => 123, :text => 'Tweet text.', :user => {:id => 123, :screen_name => "x"})
      expect(@bot.from_user(t)).to eq("x")
    end

    it "should accept user" do    
      u = Twitter::User.new(:id => 123, :name => "x")
      expect(@bot.from_user(fake_user("x"))).to eq("x")
    end
    
    it "should accept :screen_name" do
      expect(@bot.from_user(:user => {:screen_name => "x"})).to eq("x")
    end
  end
  
  describe "#botname" do    
    before(:each) do
      class TestBot < Chatterbot::Bot; end
      @bot = Chatterbot::Bot.new
    end

    it "can set botname" do
      @bot = TestBot.new
      @bot.botname = "foo"
      expect(@bot.botname).to eq("foo")
    end
    
    it "calls botname smartly for inherited classes" do
      @bot2 = TestBot.new
      expect(@bot2.botname).to eq("testbot")
    end

    it "calls botname for non-inherited bots" do
      expect(File).to receive(:basename).and_return("bot")
      expect(@bot.botname).to eq("bot")
    end

    it "uses specified name" do
      @bot = Chatterbot::Bot.new(:name => 'xyzzy')
      expect(@bot.botname).to eq("xyzzy")
    end
  end

  describe "#replace_variables" do
    before(:each) do
      @bot = Chatterbot::Bot.new(:name => 'xyzzy')
      @tweet = {}
    end

    it "should replace username by calling tweet_user" do
      expect(@bot).to receive(:tweet_user).and_return("@foobar")
      expect(@bot.replace_variables("#USER#", @tweet)).to eq("@foobar")
    end
    
    it "should be fine with not replacing anything" do
      expect(@bot.replace_variables("foobar", @tweet)).to eq("foobar")
    end
    
    it "should be fine without a tweet" do
      expect(@bot.replace_variables("foobar")).to eq("foobar")
    end
  end  
end
