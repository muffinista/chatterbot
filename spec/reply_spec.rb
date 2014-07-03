require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Reply" do
  it "calls require_login" do
    bot = test_bot
    expect(bot).to receive(:require_login).and_return(false)
    bot.replies
  end

  it "updates since_id_reply when complete" do
    bot = test_bot
    expect(bot).to receive(:require_login).and_return(true)
    results = fake_replies(1, 1000)

    allow(bot).to receive(:client).and_return(results)
    
    bot.replies do
    end

    expect(bot.config[:tmp_since_id_reply]).to eq(1000)
  end

  it "iterates results" do
    bot = test_bot
    expect(bot).to receive(:require_login).and_return(true)
    allow(bot).to receive(:client).and_return(fake_replies(3))
    
    expect(bot).to receive(:update_since_id_reply).exactly(3).times

    indexes = []
    bot.replies do |x|
      indexes << x[:id]
    end

    expect(indexes).to eq([1,2,3])
  end

  it "checks blacklist" do
    bot = test_bot
    expect(bot).to receive(:require_login).and_return(true)
    allow(bot).to receive(:client).and_return(fake_replies(3))
    
    allow(bot).to receive(:on_blacklist?).and_return(true, false, false)


    indexes = []
    bot.replies do |x|
      indexes << x[:id]
    end

    expect(indexes).to eq([2,3])
  end


  it "passes along since_id_reply" do
    bot = test_bot
    expect(bot).to receive(:require_login).and_return(true)
    allow(bot).to receive(:client).and_return(fake_replies(100, 3))    
    allow(bot).to receive(:since_id_reply).and_return(123)
    
    expect(bot.client).to receive(:mentions_timeline).with({:since_id => 123, :count => 200})

    bot.replies
  end
  

  it "doesn't pass along invalid since_id_reply" do
    bot = test_bot
    expect(bot).to receive(:require_login).and_return(true)
    allow(bot).to receive(:client).and_return(fake_replies(100, 3))    
    allow(bot).to receive(:since_id_reply).and_return(0)
    
    expect(bot.client).to receive(:mentions_timeline).with({:count => 200})

    bot.replies
  end

  it "pass along since_id if since_id_reply is nil or zero" do
    bot = test_bot
    expect(bot).to receive(:require_login).and_return(true)
    allow(bot).to receive(:client).and_return(fake_replies(100, 3))
    allow(bot).to receive(:since_id).and_return(12345)

    expect(bot.client).to receive(:mentions_timeline).with({:count => 200, :since_id => 12345})

    bot.replies

  end
end
