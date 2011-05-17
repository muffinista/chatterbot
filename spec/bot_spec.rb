require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Bot" do
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
