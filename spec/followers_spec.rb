require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Followers" do
  it "calls require_login" do
    bot = test_bot
    bot.should_receive(:require_login).and_return(false)
    bot.followers
  end

  it "returns followers" do
    bot = test_bot
    bot.should_receive(:require_login).and_return(true)
    bot.stub!(:client).and_return(fake_followers(3))

    result = bot.followers
    result.size.should == 3
    result[0].name.should == "Follower 1"
  end
end
