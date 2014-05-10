require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Followers" do
  before(:each) do
    @bot = test_bot
  end

  describe "followers" do
    it "calls require_login" do
      @bot.should_receive(:require_login).and_return(false)
      @bot.followers
    end

    it "returns followers" do
      @bot.should_receive(:require_login).and_return(true)
      @bot.stub(:client).and_return(fake_followers(3))

      result = @bot.followers
      result.size.should == 3
      result[0].name.should == "Follower 1"
    end
  end

  describe "follow" do
    it "calls require_login" do
      @bot.should_receive(:require_login).and_return(false)
      @bot.follow(1234)
    end

    it "works" do
      @bot.should_receive(:require_login).and_return(true)
      @bot.stub(:client).and_return(double(Twitter::Client))
      @bot.client.should_receive(:follow).with(1234)
      
      @bot.follow(1234)
    end
  end

  
end
