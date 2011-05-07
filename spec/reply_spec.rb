require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Reply" do
  it "calls require_login" do
    bot = Chatterbot::Bot.new
    bot.should_receive(:require_login).and_return(false)
    bot.replies
  end

  # it "calls update_since_id" do
  #   bot = Chatterbot::Bot.new
  #   bot.should_receive(:require_login).and_return(true)
  #   bot.stub!(:client).and_return(fake_replies(100))
  #   bot.should_receive(:update_since_id).with({'results' => []})

  #   bot.replies
  # end

  it "iterates results" do
    bot = Chatterbot::Bot.new
    bot.should_receive(:require_login).and_return(true)
    bot.stub!(:client).and_return(fake_replies(100, 3))
    
    bot.should_receive(:update_since_id).exactly(3).times

    indexes = []
    bot.replies do |x|
      indexes << x[:index]
    end

    indexes.should == [1,2,3]
  end

  it "checks blacklist" do
    bot = Chatterbot::Bot.new
    bot.should_receive(:require_login).and_return(true)
    bot.stub!(:client).and_return(fake_replies(100, 3))
    
    bot.should_receive(:update_since_id).exactly(2).times

    bot.stub!(:on_blacklist?).and_return(true, false)

    indexes = []
    bot.replies do |x|
      indexes << x[:index]
    end

    indexes.should == [2,3]
  end

end
