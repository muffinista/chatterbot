require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::DirectMessages" do
  it "calls require_login" do
    bot = test_bot
    expect(bot).to receive(:require_login).and_return(false)
    bot.direct_messages
  end

  it "updates since_id_dm when complete" do
    bot = test_bot
    expect(bot).to receive(:require_login).and_return(true)
    results = fake_direct_messages(1, 1000)

    allow(bot).to receive(:client).and_return(results)
    
    bot.direct_messages do
    end

    expect(bot.config[:since_id_dm]).to eq(1000)
  end

  it "iterates results" do
    bot = test_bot
    expect(bot).to receive(:require_login).and_return(true)
    allow(bot).to receive(:client).and_return(fake_direct_messages(3))
    
    expect(bot).to receive(:update_since_id_dm).exactly(3).times

    indexes = []
    bot.direct_messages do |x|
      indexes << x[:id]
    end

    expect(indexes).to eq([1,2,3])
  end

  it "checks blocklist" do
    bot = test_bot
    expect(bot).to receive(:require_login).and_return(true)
    allow(bot).to receive(:client).and_return(fake_direct_messages(3))
    
    allow(bot).to receive(:on_blocklist?).and_return(true, false, false)


    indexes = []
    bot.direct_messages do |x|
      indexes << x[:id]
    end

    expect(indexes).to eq([2,3])
  end


  it "passes along since_id_dm" do
    bot = test_bot
    expect(bot).to receive(:require_login).and_return(true)
    allow(bot).to receive(:client).and_return(fake_direct_messages(100, 3))    
    allow(bot).to receive(:since_id_dm).and_return(123)
    
    expect(bot.client).to receive(:direct_messages_received).with({:since_id => 123, :count => 200})

    bot.direct_messages
  end
end
