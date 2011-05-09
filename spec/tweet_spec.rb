require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Tweet" do
  describe "#tweet" do
    before(:each) do
      @bot = test_bot
    end

    it "calls require_login when tweeting" do
      @bot.should_receive(:require_login).and_return(false)
      @bot.tweet "tweet test!"
    end

    it "calls client.update with the right values" do
      bot = test_bot
#      bot = Chatterbot::Bot.new
      bot.should_receive(:require_login).and_return(true)
      bot.stub!(:client).and_return(mock(TwitterOAuth::Client))

      bot.stub!(:debug_mode?).and_return(false)

      test_str = "test!"
      bot.client.should_receive(:update).with(test_str, {})
      bot.tweet test_str
    end

    it "doesn't tweet when debug_mode? is set" do
      bot = test_bot
#      bot = Chatterbot::Bot.new
      bot.should_receive(:require_login).and_return(true)
      bot.stub!(:client).and_return(mock(TwitterOAuth::Client))

      bot.stub!(:debug_mode?).and_return(true)

      bot.client.should_not_receive(:update)
      bot.tweet "no tweet!"
    end
  end

  describe "#reply" do
    it "calls require_login when replying" do
#      bot = Chatterbot::Bot.new
      bot = test_bot
      bot.should_receive(:require_login).and_return(false)
      bot.reply "reply test!", {"id" => 100}
    end


    it "calls client.update with the right values" do
#      bot = Chatterbot::Bot.new
      bot = test_bot
      bot.should_receive(:require_login).and_return(true)
      bot.stub!(:client).and_return(mock(TwitterOAuth::Client))

      bot.stub!(:debug_mode?).and_return(false)

      test_str = "test!"

      s = {
        'id' => 100
      }
      bot.client.should_receive(:update).with(test_str, {:in_reply_to_status_id => 100})
      bot.reply test_str, s
    end


    it "doesn't reply when debug_mode? is set" do
#      bot = Chatterbot::Bot.new
      bot = test_bot
      bot.should_receive(:require_login).and_return(true)
      bot.stub!(:client).and_return(mock(TwitterOAuth::Client))

      bot.stub!(:debug_mode?).and_return(true)

      bot.client.should_not_receive(:update)
      bot.reply "no reply test!", {"id" => 100}
    end
  end

end
