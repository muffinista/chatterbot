require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Tweet" do
  describe "#tweet" do
    before(:each) do
      @bot = test_bot
    end

    it "calls require_login when tweeting" do
      expect(@bot).to receive(:require_login).and_return(false)
      @bot.tweet "tweet test!"
    end

    it "calls client.update with the right values" do
      bot = test_bot

      expect(bot).to receive(:require_login).and_return(true)
      allow(bot).to receive(:client).and_return(double(Twitter::Client))

      allow(bot).to receive(:debug_mode?).and_return(false)

      test_str = "test!"
      expect(bot.client).to receive(:update).with(test_str, {})
      bot.tweet test_str
    end

    it "doesn't tweet when debug_mode? is set" do
      bot = test_bot
      
      expect(bot).to receive(:require_login).and_return(true)
      allow(bot).to receive(:client).and_return(double(Twitter::Client))

      allow(bot).to receive(:debug_mode?).and_return(true)

      expect(bot.client).not_to receive(:update)
      bot.tweet "no tweet!"
    end
  end

  describe "#reply" do
    it "calls require_login when replying" do
      bot = test_bot
      expect(bot).to receive(:require_login).and_return(false)
      bot.reply "reply test!", {"id" => 100}
    end

    it "calls client.update with the right values" do
      bot = test_bot
      expect(bot).to receive(:require_login).and_return(true)
      allow(bot).to receive(:client).and_return(double(Twitter::Client))

      allow(bot).to receive(:debug_mode?).and_return(false)

      test_str = "test!"

      s = {
        :id => 100
      }
      expect(bot.client).to receive(:update).with(test_str, {:in_reply_to_status_id => 100})
      bot.reply test_str, s
    end


    it "doesn't reply when debug_mode? is set" do
      bot = test_bot
      expect(bot).to receive(:require_login).and_return(true)
      allow(bot).to receive(:client).and_return(double(Twitter::Client))

      allow(bot).to receive(:debug_mode?).and_return(true)

      expect(bot.client).not_to receive(:update)
      bot.reply "no reply test!", {:id => 100}
    end
  end

end
