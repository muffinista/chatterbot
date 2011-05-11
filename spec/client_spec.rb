require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Client" do
  before(:each) do
    @bot = Chatterbot::Bot.new    
  end
  
  it "runs init_client and login on #require_login" do
    @bot.should_receive(:init_client).and_return(true)
    @bot.should_receive(:login).and_return(true)
    @bot.require_login
  end
end
