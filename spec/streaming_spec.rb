require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Streaming" do
  before(:each) do
    @bot = Chatterbot::Bot.new
    @streamer = double(Twitter::Streaming::Client)
    allow(@streamer).to receive(:user).and_yield(fake_tweet(50, 50))
    @bot.stub(:streaming_client).and_return(@streamer)
  end

  describe "streaming tweets" do
    it "should pass default opts along" do
      @streamer.should_receive(:user).with(:with => "false", :replies => "true", :stall_warnings => "false")
      @bot.streaming_tweets {}     
    end

    it "should pass extra opts" do
      @streamer.should_receive(:user).with(:with => "false", :replies => "false", :stall_warnings => "false", :track => "foobar")
      @bot.streaming_tweets(:replies => false, :track => "foobar") {}
    end

    it "should call block" do
      @bot.streaming_tweets(:replies => false, :track => "foobar") { |x| @result = x }
      @result.should be_a(Twitter::Tweet)
    end
  end
end
