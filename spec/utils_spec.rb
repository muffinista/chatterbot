require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Utils" do
  before(:each) do
    @bot = test_bot
  end
  
  describe "id_from_tweet" do
    it "works with numbers" do
      @bot.id_from_tweet(1234).should == 1234
    end
    
    it "works with tweets" do
      t = Twitter::Tweet.new(:id => 7890, :text => "did you know that i hate bots?")
      @bot.id_from_tweet(t).should == 7890
    end
  end
  
  describe "id_from_user" do
    it "works with numbers" do
      @bot.id_from_user(1234).should == 1234
    end
    
    it "works with users" do
      t = Twitter::User.new(:id => 2345, :name => "name")
      @bot.id_from_user(t).should == 2345
    end
  end
end
