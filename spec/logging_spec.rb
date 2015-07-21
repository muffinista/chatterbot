require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'tempfile'

describe "Chatterbot::Logging" do
  describe "debug logging" do
    before(:each) do
      @bot = Chatterbot::Bot.new
      @logger = double(Logger)
      allow(@bot).to receive(:logger).and_return(@logger)
    end

    it "should call logger on debug" do
      expect(@bot).to receive(:logging?).and_return(true)
      expect(@logger).to receive(:debug).with("rspec hi!")
      @bot.debug "hi!"
    end

    it "should not call logger when not logging desired" do
      expect(@bot).to receive(:logging?).and_return(false)
      expect(@logger).not_to receive(:debug)
      @bot.debug "hi!"
    end

    it "should call logger and also print output when critical" do
      expect(@bot).to receive(:logging?).and_return(true)
      expect(@logger).to receive(:debug).with("rspec hi!")      
      expect(@bot).to receive(:puts).with("hi!")
      @bot.critical "hi!"
    end
  end
  
end
