require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::DirectMessages" do
  let(:bot) { test_bot }

  describe "direct_message" do
    it "calls require_login" do
      expect(bot).to receive(:require_login).and_return(false)
      bot.direct_message("hello")
    end

    context "when authenticated" do
      before(:each) do
        expect(bot).to receive(:require_login).and_return(true)
        allow(bot).to receive(:client).and_return(double(Twitter::Client))
        allow(bot).to receive(:debug_mode?).and_return(false)
      end

      it "calls create_direct_message" do
        test_str = "test!"
        test_user = fake_user("DM Enthusiast")

        expect(bot.client).to receive(:create_direct_message).with(test_user, test_str)
        bot.direct_message(test_str, test_user)
      end

      it "grabs user from most recent tweet object if needed" do
        test_str = "test!"
        test_user = fake_user("DM Enthusiast", 1000)

        x = {
          :from_user => "chatterbot",
          :id => 100,
          :text => "I am a tweet",
          :user => { :id => 1000, :screen_name => "DM Enthusiast" }
        }

        t = Twitter::Tweet.new(x)
        bot.instance_variable_set(:@current_tweet, t)

        expect(bot.client).to receive(:create_direct_message).with(test_user, test_str)
        bot.direct_message(test_str)
      end
    end
  end

  describe "direct_messages" do
    it "calls require_login" do
      expect(bot).to receive(:require_login).and_return(false)
      bot.direct_messages
    end

    it "updates since_id_dm when complete" do
      expect(bot).to receive(:require_login).and_return(true)
      results = fake_direct_messages(1, 1000)

      allow(bot).to receive(:client).and_return(results)

      bot.direct_messages do
      end

      expect(bot.config[:since_id_dm]).to eq(1000)
    end

    describe "results handling" do
      before(:each) do
        expect(bot).to receive(:require_login).and_return(true)
        allow(bot).to receive(:client).and_return(fake_direct_messages(3))
      end

      it "iterates results" do

        expect(bot).to receive(:update_since_id_dm).exactly(3).times

        indexes = []
        bot.direct_messages do |x|
          indexes << x.id
        end

        expect(indexes).to eq([1,2,3])
      end

      it "checks blocklist" do
        allow(bot).to receive(:on_blocklist?).and_return(true, false, false)
        indexes = []
        bot.direct_messages do |x|
          indexes << x.id
        end

        expect(indexes).to eq([2,3])
      end

      it "checks safelist" do
        allow(bot).to receive(:has_safelist?).and_return(true)
        allow(bot).to receive(:on_safelist?).and_return(false, true, false)

        indexes = []
        bot.direct_messages do |x|
          indexes << x.id
        end

        expect(indexes).to eq([2])
      end


      it "passes along since_id_dm" do
        allow(bot).to receive(:since_id_dm).and_return(123)

        expect(bot.client).to receive(:direct_messages_received).with({:since_id => 123, :count => 200})

        bot.direct_messages
      end
    end
  end
end
