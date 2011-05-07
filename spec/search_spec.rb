require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Botter::Search" do
  it "calls search" do
    bot = Botter::Bot.new
    bot.should_receive(:search)
    bot.search("foo")
  end

  it "calls init_client" do
    bot = Botter::Bot.new
    bot.should_receive(:init_client).and_return(false)
    bot.search("foo")
  end

  it "calls update_since_id" do
    bot = Botter::Bot.new

    bot.stub!(:client).and_return(fake_search(100))
    bot.should_receive(:update_since_id).with({'max_id' => 100, 'results' => []})

    bot.search("foo")
  end

  it "iterates results" do
    bot = Botter::Bot.new
    bot.stub!(:client).and_return(fake_search(100, 3))
    
    indexes = []
    bot.search("foo") do |x|
      indexes << x[:index]
    end

    indexes.should == [1,2,3]
  end

  it "checks blacklist" do
    bot = Botter::Bot.new
    bot.stub!(:client).and_return(fake_search(100, 3))
    
    bot.stub!(:on_blacklist?).and_return(true, false)
    
    indexes = []
    bot.search("foo") do |x|
      indexes << x[:index]
    end

    indexes.should == [2,3]
  end

end
