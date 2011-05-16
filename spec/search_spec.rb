require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Search" do
  it "calls search" do
    bot = Chatterbot::Bot.new
    bot.should_receive(:search)
    bot.search("foo")
  end

  it "calls init_client" do
    bot = test_bot
    bot.should_receive(:init_client).and_return(false)
    bot.search("foo")
  end

  it "calls update_since_id" do
    bot = test_bot

    bot.stub!(:client).and_return(fake_search(100))
    bot.should_receive(:update_since_id).with({'max_id' => 100, 'results' => []})

    bot.search("foo")
  end

  it "accepts multiple searches at once" do
    bot = test_bot
    #bot = Chatterbot::Bot.new

    bot.stub!(:client).and_return(fake_search(100))
    bot.client.should_receive(:search).with("foo", {:since_id => 0})
    bot.client.should_receive(:search).with("bar", {:since_id => 0})    

    bot.search(["foo", "bar"])
  end

  it "accepts a single search query" do
    bot = test_bot

    bot.stub!(:client).and_return(fake_search(100))
    bot.client.should_receive(:search).with("foo", {:since_id => 0})

    bot.search("foo")
  end
  
  it "iterates results" do
    bot = test_bot
#    bot = Chatterbot::Bot.new
    bot.stub!(:client).and_return(fake_search(100, 3))

    indexes = []
    bot.search("foo") do |x|
      indexes << x[:index]
    end

    indexes.should == [1,2,3]
  end

  it "checks blacklist" do
    bot = test_bot
#    bot = Chatterbot::Bot.new
    bot.stub!(:client).and_return(fake_search(100, 3))
    
    bot.stub!(:on_blacklist?).and_return(true, false)
    
    indexes = []
    bot.search("foo") do |x|
      indexes << x[:index]
    end

    indexes.should == [2,3]
  end

end
