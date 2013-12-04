require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Retweet" do
  describe "#retweet" do
    before(:each) do
      @bot = test_bot
    end

    it "calls require_login when tweeting" do
      @bot.should_receive(:require_login).and_return(false)
      @bot.retweet "tweet test!"
    end

    it "calls client.retweet with the right values" do
      bot = test_bot

      bot.should_receive(:require_login).and_return(true)
      bot.stub(:client).and_return(mock(Twitter::Client))

      bot.stub(:debug_mode?).and_return(false)

      tweet_id = 12345
      bot.client.should_receive(:retweet).with(tweet_id)
      bot.retweet(tweet_id)
    end
  end
end
