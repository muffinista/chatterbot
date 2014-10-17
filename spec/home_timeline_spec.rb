require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::HomeTimeline" do
  it "calls require_login" do
    bot = test_bot
    expect(bot).to receive(:require_login).and_return(false)
    bot.home_timeline
  end

  it "updates since_id when complete" do
    bot = test_bot
    expect(bot).to receive(:require_login).and_return(true)
    results = fake_home_timeline(1, 1000)

    allow(bot).to receive(:client).and_return(results)
    
    bot.home_timeline do
    end

    expect(bot.config[:tmp_since_id]).to eq(1000)
  end

  it "iterates results" do
    bot = test_bot
    expect(bot).to receive(:require_login).and_return(true)
    allow(bot).to receive(:client).and_return(fake_home_timeline(3))
    
    expect(bot).to receive(:update_since_id).exactly(3).times

    indexes = []
    bot.home_timeline do |x|
      indexes << x[:id]
    end

    expect(indexes).to eq([1,2,3])
  end

  it "checks blacklist" do
    bot = test_bot
    expect(bot).to receive(:require_login).and_return(true)
    allow(bot).to receive(:client).and_return(fake_home_timeline(3))
    
    allow(bot).to receive(:on_blacklist?).and_return(true, false, false)


    indexes = []
    bot.home_timeline do |x|
      indexes << x[:id]
    end

    expect(indexes).to eq([2,3])
  end
end
