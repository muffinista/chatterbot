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

    context "when authenticated" do
      let(:bot) { test_bot }
      before(:each) do
        expect(bot).to receive(:require_login).and_return(true)
        allow(bot).to receive(:client).and_return(double(Twitter::Client))
      end
      
      it "calls client.update with the right values" do
        allow(bot).to receive(:debug_mode?).and_return(false)

        test_str = "test!"
        expect(bot.client).to receive(:update).with(test_str, {})
        bot.tweet test_str
      end

      it "calls client.update_with_media if media file is specified" do
        allow(bot).to receive(:debug_mode?).and_return(false)

        test_str = "test!"
        path = File.join(File.dirname(__FILE__), "fixtures", "update_with_media.png")
        media = File.new(path)
        expect(bot.client).to receive(:update_with_media).with(test_str, media, {})
        bot.tweet test_str, media:media
      end

      it "calls client.update_with_media if media file path is specified" do
        allow(bot).to receive(:debug_mode?).and_return(false)

        test_str = "test!"
        path = File.join(File.dirname(__FILE__), "fixtures", "update_with_media.png")

        expect(bot.client).to receive(:update_with_media).with(test_str, an_instance_of(File), {})
        bot.tweet test_str, media:path
      end

      
      it "doesn't tweet when debug_mode? is set" do
        allow(bot).to receive(:debug_mode?).and_return(true)

        expect(bot.client).not_to receive(:update)
        bot.tweet "no tweet!"
      end
    end
  end

  describe "#reply" do
    it "calls require_login when replying" do
      bot = test_bot
      expect(bot).to receive(:require_login).and_return(false)
      bot.reply "reply test!", fake_tweet(100)
    end

    context "when authenticated" do
      let(:bot) { test_bot }
      before(:each) do
        expect(bot).to receive(:require_login).and_return(true)
        allow(bot).to receive(:client).and_return(double(Twitter::Client))
      end

      
      it "calls client.update with the right values" do
        allow(bot).to receive(:debug_mode?).and_return(false)

        test_str = "test!"

        expect(bot.client).to receive(:update).with(test_str, {:in_reply_to_status_id => 100})
        bot.reply test_str, fake_tweet(100, 100)
      end

      it "calls client.update_with_media if media file is specified" do
        allow(bot).to receive(:debug_mode?).and_return(false)

        test_str = "test!"
        path = File.join(File.dirname(__FILE__), "fixtures", "update_with_media.png")
        media = File.new(path)

        expect(bot.client).to receive(:update_with_media).with(test_str, media, {:in_reply_to_status_id => 100})
        bot.reply test_str, fake_tweet(100, 100), media:media
      end

      it "calls client.update_with_media if media file path is specified" do
        allow(bot).to receive(:debug_mode?).and_return(false)

        test_str = "test!"
        path = File.join(File.dirname(__FILE__), "fixtures", "update_with_media.png")

        expect(bot.client).to receive(:update_with_media).with(test_str, an_instance_of(File), {:in_reply_to_status_id => 100})
        bot.reply test_str, fake_tweet(100, 100), media:path
      end

      it "doesn't reply when debug_mode? is set" do
        allow(bot).to receive(:debug_mode?).and_return(true)

        expect(bot.client).not_to receive(:update_with_media)
        bot.reply "no reply test!", fake_tweet(100)
      end
    end
  end
  
end
