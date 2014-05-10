require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Favorite" do
  describe "#favorite" do
    before(:each) do
      @bot = test_bot
      @t = Twitter::Tweet.new(:id => 7890, :text => "something awesome that you should fave")
    end

    it "calls require_login" do
      @bot.should_receive(:require_login).and_return(false)
      @bot.favorite @t
    end

    context "data" do
      before(:each) do
        @bot.should_receive(:require_login).and_return(true)
        @bot.stub(:client).and_return(double(Twitter::Client))

        @bot.stub(:debug_mode?).and_return(false)
      end

      it "calls client.favorite with an id" do   
        @bot.client.should_receive(:favorite).with(7890)
        @bot.favorite(@t.id)
      end

      it "calls client.retweet with a tweet" do   
        @bot.client.should_receive(:favorite).with(7890)
        @bot.favorite(@t)
      end
    end
  end
end
