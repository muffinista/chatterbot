require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Search" do
  it "calls search" do
    bot = Chatterbot::Bot.new
    expect(bot).to receive(:search)
    bot.search("foo")
  end
 

  it "calls update_since_id" do
    bot = test_bot
    
    data = fake_search(100, 1)
    allow(bot).to receive(:client).and_return(data)
    expect(bot).to receive(:update_since_id).with(data.search[0])
    
    bot.search("foo")
  end

  it "accepts multiple searches at once" do
    bot = test_bot
    
    allow(bot).to receive(:client).and_return(fake_search(100, 1))
    expect(bot.client).to receive(:search).once.ordered.with("foo", {:result_type=>"recent"})
    expect(bot.client).to receive(:search).once.ordered.with("bar", {:result_type=>"recent"})

    bot.search(["foo", "bar"])
  end

  it "accepts extra params" do
    bot = test_bot

    allow(bot).to receive(:client).and_return(fake_search(100, 1))
    expect(bot.client).to receive(:search).with("foo", {:lang => "en", :result_type=>"recent"})

    bot.search("foo", :lang => "en")
  end

  it "accepts a single search query" do
    bot = test_bot

    allow(bot).to receive(:client).and_return(fake_search(100, 1))
    expect(bot.client).to receive(:search).with("foo", {:result_type=>"recent"})

    bot.search("foo")
  end

  it "passes along since_id" do
    bot = test_bot
    allow(bot).to receive(:since_id).and_return(123)
    allow(bot).to receive(:since_id_reply).and_return(456)
    
    allow(bot).to receive(:client).and_return(fake_search(100, 1))
    expect(bot.client).to receive(:search).with("foo", {:since_id => 123, :result_type => "recent", :since_id_reply => 456})

    bot.search("foo")
  end

  it "updates since_id when complete" do
    bot = test_bot
    results = fake_search(1000, 1)
    allow(bot).to receive(:client).and_return(results)
    
    expect(bot).to receive(:update_since_id).with(results.search[0])
    bot.search("foo")
  end
  
  it "iterates results" do
    bot = test_bot
    allow(bot).to receive(:client).and_return(fake_search(100, 3))
    indexes = []

    bot.search("foo") do |x|
      indexes << x.attrs[:index]
    end
    
    expect(indexes).to eq([100, 99, 98])
  end

  it "checks blacklist" do
    bot = test_bot
    allow(bot).to receive(:client).and_return(fake_search(100, 3))
    
    allow(bot).to receive(:on_blacklist?).and_return(true, false)
    
    indexes = []
    bot.search("foo") do |x|
      indexes << x.attrs[:index]
    end

    expect(indexes).to eq([99, 98])
  end

end
