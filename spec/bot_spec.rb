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

  describe "run_or_stream" do
    it "should use streaming if specified" do
      expect(@bot).to receive(:stream!)
      @bot.streaming = true
      @bot.run_or_stream
    end

    it "should use streaming if required by handler" do
      expect(@bot).to receive(:stream!)
      @bot.register_handler(:deleted) {}
      @bot.run_or_stream
    end

    it "should use REST if specified" do
      expect(@bot).to receive(:run!)
      @bot.run_or_stream
    end
  end
end
