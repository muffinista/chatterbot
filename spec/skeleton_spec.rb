require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'chatterbot/skeleton'

describe "Chatterbot::Skeleton" do
  before(:each) do
    @bot = Chatterbot::Bot.new
    @bot.config = {
      :consumer_key => "consumer_key",
      :consumer_secret => "consumer_secret",
      :secret => "secret",
      :token => "token"
    }
    @bot.stub!(:botname).and_return("Skelley_The_Skeleton")

    @output = Chatterbot::Skeleton.generate(@bot)
  end

  it "should have name" do
    @output.should include("Skelley_The_Skeleton")
  end 

  it "should have auth info" do
    @output.should include("'consumer_key'")
    @output.should include("'consumer_secret'")
    @output.should include("'secret'")
    @output.should include("'token'")
  end 
end
