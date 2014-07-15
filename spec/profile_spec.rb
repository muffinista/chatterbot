require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Profile" do
  describe "#profile_text" do
    let(:user) { fake_user('user', 100) }
    let(:bot) { test_bot }


    it "calls require_login" do
      expect(bot).to receive(:require_login).and_return(false)
      bot.profile_text "set my profile!"
    end

    context "data" do
      before(:each) do
        expect(bot).to receive(:require_login).and_return(true)
        allow(bot).to receive(:client).and_return(double(Twitter::Client))

        allow(bot).to receive(:debug_mode?).and_return(false)
      end

      it "calls client.user to get" do   
        expect(bot.client).to receive(:user).and_return(user)
        bot.profile_text
      end

      it "calls client.update_profile to set" do   
        expect(bot.client).to receive(:update_profile).with(description:"hello")
        bot.profile_text "hello"
      end
    end
  end


  describe "#profile_website" do
    let(:user) { fake_user('user', 100) }
    let(:bot) { test_bot }


    it "calls require_login" do
      expect(bot).to receive(:require_login).and_return(false)
      bot.profile_website "set my profile!"
    end

    context "data" do
      before(:each) do
        expect(bot).to receive(:require_login).and_return(true)
        allow(bot).to receive(:client).and_return(double(Twitter::Client))

        allow(bot).to receive(:debug_mode?).and_return(false)
      end

      it "calls client.user to get" do   
        expect(bot.client).to receive(:user).and_return(user)
        bot.profile_website
      end

      it "calls client.update_profile to set" do   
        expect(bot.client).to receive(:update_profile).with(url:"http://hello.com")
        bot.profile_website "http://hello.com"
      end
    end
  end
  
end
