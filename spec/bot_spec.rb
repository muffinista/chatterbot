require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Bot" do
  before(:each) do
    @bot = Chatterbot::Bot.new
  end

  describe "Streaming API" do
    it "should call streaming_client.user" do
      expect(@bot.streaming_client).to receive(:user)
      @bot.stream!
    end
  end

  describe "REST API" do
    it "should work" do
      expect(@bot).to receive(:require_login).and_return(true)
      expect(@bot).to receive(:client).and_return(fake_home_timeline(3))
      @bot.register_handler(:home_timeline) {}
      @bot.run!
    end
  end
end
