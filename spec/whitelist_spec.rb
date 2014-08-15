require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Whitelist" do
  describe "on_whitelist?" do
    before(:each) do
      @bot = test_bot
      @bot.whitelist = [fake_user('user', 100), "skippy", "blippy", "dippy"]
    end

    it "includes users we want" do
      expect(@bot.on_whitelist?("user")).to eq(true)
      expect(@bot.on_whitelist?("skippy")).to eq(true)
    end

    it "excludes users we don't want" do
      expect(@bot.on_whitelist?("flippy")).to eq(false)
    end

    it "isn't case-specific" do
      expect(@bot.on_whitelist?("FLIPPY")).to eq(false)
      expect(@bot.on_whitelist?("SKIPPY")).to eq(true)
    end

    it "works with result hashes" do
      expect(@bot.on_whitelist?(Twitter::Tweet.new(:id => 1,
                                            :user => {:id => 1, :screen_name => "skippy"}))).to eq(true)
      expect(@bot.on_whitelist?(Twitter::Tweet.new(:id => 1,
                                            :user => {:id => 1, :screen_name => "flippy"}))).to eq(false)
    end   
  end
end
