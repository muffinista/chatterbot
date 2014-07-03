require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Utils" do
  before(:each) do
    @bot = test_bot
  end
  
  describe "id_from_tweet" do
    it "works with numbers" do
      expect(@bot.id_from_tweet(1234)).to eq(1234)
    end
    
    it "works with tweets" do
      t = Twitter::Tweet.new(:id => 7890, :text => "did you know that i hate bots?")
      expect(@bot.id_from_tweet(t)).to eq(7890)
    end
  end
  
  describe "id_from_user" do
    it "works with numbers" do
      expect(@bot.id_from_user(1234)).to eq(1234)
    end
    
    it "works with users" do
      t = Twitter::User.new(:id => 2345, :name => "name")
      expect(@bot.id_from_user(t)).to eq(2345)
    end
  end
end
