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
 
  describe "#botname" do    
    before(:each) do
      @bot = Chatterbot::Bot.new
      @bot.client = mock(Object)
    end

    it "calls botname smartly for inherited classes" do
      class TestBot < Chatterbot::Bot; end
      @bot2 = TestBot.new
      @bot2.botname.should == "testbot"
    end

    it "calls botname for non-inherited bots" do
      File.should_receive(:basename).and_return("bot")
      @bot.botname.should == "bot"
    end
  end
  
end
