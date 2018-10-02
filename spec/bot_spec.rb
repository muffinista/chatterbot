require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Bot" do
  before(:each) do
    @bot = Chatterbot::Bot.new
  end


  describe "REST API" do
    it "should work" do
      allow(@bot).to receive(:require_login).and_return(false)
      allow(@bot).to receive(:client).and_return(fake_home_timeline(3))
      @bot.register_handler(:home_timeline) {}
      @bot.run!
    end
  end
end
