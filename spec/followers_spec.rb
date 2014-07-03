require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Followers" do
  before(:each) do
    @bot = test_bot
  end

  describe "followers" do
    it "calls require_login" do
      expect(@bot).to receive(:require_login).and_return(false)
      @bot.followers
    end

    it "returns followers" do
      expect(@bot).to receive(:require_login).and_return(true)
      allow(@bot).to receive(:client).and_return(fake_followers(3))

      result = @bot.followers
      expect(result.size).to eq(3)
      expect(result[0].name).to eq("Follower 1")
    end
  end

  describe "follow" do
    it "calls require_login" do
      expect(@bot).to receive(:require_login).and_return(false)
      @bot.follow(1234)
    end

    it "works" do
      expect(@bot).to receive(:require_login).and_return(true)
      allow(@bot).to receive(:client).and_return(double(Twitter::Client))
      expect(@bot.client).to receive(:follow).with(1234)
      
      @bot.follow(1234)
    end
  end

  
end
