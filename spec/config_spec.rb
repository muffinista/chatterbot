require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Search" do
  it "calls search" do
    bot = Chatterbot::Bot.new
    bot.should_receive(:search)
    bot.search("foo")
  end

  it "calls init_client" do
    bot = Chatterbot::Bot.new
    bot.should_receive(:init_client).and_return(false)
    bot.search("foo")
  end

  it "calls update_since_id" do
    bot = test_bot
    bot.stub!(:client).and_return(fake_search(100))
    bot.should_receive(:update_since_id).with({'max_id' => 100, 'results' => []})

    bot.search("foo")
  end

end
