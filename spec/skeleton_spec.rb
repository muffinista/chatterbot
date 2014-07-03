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
    allow(@bot).to receive(:botname).and_return("Skelley_The_Skeleton")

    @output = Chatterbot::Skeleton.generate(@bot)
  end

  it "should have name" do
    expect(@output).to include("Skelley_The_Skeleton")
  end 

  it "should have auth info" do
    expect(@output).to include("'consumer_key'")
    expect(@output).to include("'consumer_secret'")
    expect(@output).to include("'secret'")
    expect(@output).to include("'token'")
  end 
end
