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

    context "data" do
      before(:each) do
        @bot.should_receive(:require_login).and_return(true)
        @bot.stub(:client).and_return(double(Twitter::Client))

        @bot.stub(:debug_mode?).and_return(false)
      end

      it "calls client.retweet with an id" do   
        tweet_id = 12345
        @bot.client.should_receive(:retweet).with(tweet_id)
        @bot.retweet(tweet_id)
      end

      it "calls client.retweet with a tweet" do   
        t = Twitter::Tweet.new(:id => 7890, :text => "did you know that i hate bots?")
        @bot.client.should_receive(:retweet).with(7890)
        @bot.retweet(t)
      end
    end
  end
end
