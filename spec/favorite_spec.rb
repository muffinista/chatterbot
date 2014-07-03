require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Favorite" do
  describe "#favorite" do
    before(:each) do
      @bot = test_bot
      @t = Twitter::Tweet.new(:id => 7890, :text => "something awesome that you should fave")
    end

    it "calls require_login" do
      expect(@bot).to receive(:require_login).and_return(false)
      @bot.favorite @t
    end

    context "data" do
      before(:each) do
        expect(@bot).to receive(:require_login).and_return(true)
        allow(@bot).to receive(:client).and_return(double(Twitter::Client))

        allow(@bot).to receive(:debug_mode?).and_return(false)
      end

      it "calls client.favorite with an id" do   
        expect(@bot.client).to receive(:favorite).with(7890)
        @bot.favorite(@t.id)
      end

      it "calls client.retweet with a tweet" do   
        expect(@bot.client).to receive(:favorite).with(7890)
        @bot.favorite(@t)
      end
    end
  end
end
