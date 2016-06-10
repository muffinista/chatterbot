require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::DSL" do
  describe "client routines" do
    before(:each) do
      @bot = instance_double(Chatterbot::Bot, :config => {})
      @bot.send :require, 'chatterbot/dsl'

      allow(Chatterbot::DSL).to receive(:bot).and_return(@bot)
      allow(Chatterbot::DSL).to receive(:call_if_immediate)
    end

    describe "client" do
      it "returns the bot object" do
        expect(client).to eql(@bot.client)
      end
    end

    describe "blocklist" do
      it "#blocklist passes along to bot object" do
        expect(@bot).to receive(:blocklist=).with(["foo"])
        blocklist ["foo"]
      end

      it "#blocklist turns single-string arg into an array" do
        expect(@bot).to receive(:blocklist=).with(["foo"])
        blocklist "foo"
      end

      it "#blocklist turns comma-delimited string arg into an array" do
        expect(@bot).to receive(:blocklist=).with(["foo", "bar"])
        blocklist "foo, bar"
      end
    end

    describe "safelist" do
      it "#safelist passes along to bot object" do
        expect(@bot).to receive(:safelist=).with(["foo"])
        safelist ["foo"]
      end

      it "#safelist turns single-string arg into an array" do
        expect(@bot).to receive(:safelist=).with(["foo"])
        safelist "foo"
      end

      it "#safelist turns comma-delimited string arg into an array" do
        expect(@bot).to receive(:safelist=).with(["foo", "bar"])
        safelist "foo, bar"
      end
    end

    describe "only_interact_with_followers" do
      it "sets flag" do
        only_interact_with_followers
        expect(@bot.config[:only_interact_with_followers]).to eq(true)
      end
    end

    
    [:no_update, :debug_mode, :verbose].each do |method|
      describe method.to_s do
        it "#{method.to_s} with nil passes along true to bot object" do
          expect(@bot).to receive("#{method.to_s}=").with(true)
          send method
        end

        it "#debug_mode with false is passed" do
          expect(@bot).to receive("#{method.to_s}=").with(false)
          send method, false
        end

        it "#debug_mode with true is passed" do
          expect(@bot).to receive("#{method.to_s}=").with(true)
          send method, true
        end
      end
    end

    it "#badwords returns an array" do
      expect(bad_words).to be_a(Array)
    end
    
    describe "exclude" do
      it "#exclude passes along to bot object" do
        expect(@bot).to receive(:exclude=).with(["foo"])
        exclude ["foo"]
      end

      it "#exclude turns single-string arg into an array" do
        expect(@bot).to receive(:exclude=).with(["foo"])
        exclude "foo"
      end

      it "#exclude turns comma-delimited string arg into an array" do
        expect(@bot).to receive(:exclude=).with(["foo", "bar"])
        exclude "foo, bar"
      end
    end

    describe "search" do
      it "passes along to bot object" do
        allow(@bot).to receive(:run_or_stream)
        expect(@bot).to receive(:register_handler).with(:search, ["foo"])
        search("foo") {}
      end

      it "passes multiple queries along to bot object" do
        expect(@bot).to receive(:register_handler).with(:search, [["foo", "bar"]])
        search(["foo","bar"]) {}
      end
    end

    describe "direct_messages" do
      it "passes along to bot object" do
        expect(@bot).to receive(:register_handler).with(:direct_messages, instance_of(Proc))
        direct_messages {}
      end
    end

    describe "favorited" do
      it "passes along to bot object" do
        expect(@bot).to receive(:register_handler).with(:favorited, instance_of(Proc))

        favorited {}
      end
    end

    describe "followed" do
      it "passes along to bot object" do
        expect(@bot).to receive(:register_handler).with(:followed, instance_of(Proc))

        followed {}
      end
    end

    describe "deleted" do
      it "passes along to bot object" do
        expect(@bot).to receive(:register_handler).with(:deleted, instance_of(Proc))

        deleted {}
      end
    end

   
    describe "streaming" do
      it "passes along to bot object" do
        expect(@bot).to receive(:streaming=).with(true)
        use_streaming
      end
    end

    
    it "#retweet passes along to bot object" do
      expect(@bot).to receive(:retweet).with(1234)
      retweet(1234)
    end

    it "#favorite passes along to bot object" do
      expect(@bot).to receive(:favorite).with(1234)
      favorite(1234)
    end
    
    it "#replies passes along to bot object" do
      expect(@bot).to receive(:register_handler).with(:replies, instance_of(Proc))
      replies {}
    end
    
    it "#home_timeline passes along to bot object" do
      expect(@bot).to receive(:register_handler).with(:home_timeline, instance_of(Proc))
      home_timeline { |x| "foo" }
    end
    
    it "#followers passes along to bot object" do
      expect(@bot).to receive(:followers)
      followers
    end

    it "#follow passes along to bot object" do
      expect(@bot).to receive(:follow).with(1234)
      follow(1234)
    end
    
    it "#tweet passes along to bot object" do
      expect(@bot).to receive(:tweet).with("hello sailor!", {:foo => "bar" }, nil)
      tweet "hello sailor!", {:foo => "bar"}
    end

    it "#reply passes along to bot object" do
      source = double(Twitter::Tweet)
      expect(@bot).to receive(:reply).with("hello sailor!", source, {})
      reply "hello sailor!", source
    end

    it "#reply passes along to bot object with media" do
      source = double(Twitter::Tweet)
      expect(@bot).to receive(:reply).with("hello sailor!", source, {media:"/tmp/foo.jpg"})
      reply "hello sailor!", source, media:"/tmp/foo.jpg"
    end
    
    describe "#direct_message" do
      it "passes along to bot object" do
        expect(@bot).to receive(:direct_message).with("hello sailor!", nil)
        direct_message "hello sailor!"
      end

      it "passes along to bot object with user, if specified" do
        user = fake_user("DM user")
        expect(@bot).to receive(:direct_message).with("hello sailor!", user)
        direct_message "hello sailor!", user
      end
    end

    it "#profile_text setter passes along to bot object" do
      expect(@bot).to receive(:profile_text).with("hello sailor!")
      profile_text "hello sailor!"
    end

    it "#profile_text getter passes along to bot object" do
      expect(@bot).to receive(:profile_text)
      profile_text
    end

    it "#profile_website passes along to bot object" do
      expect(@bot).to receive(:profile_website).with("http://hellosailor.com")
      profile_website "http://hellosailor.com"
    end

    it "#profile_website getter passes along to bot object" do
      expect(@bot).to receive(:profile_website)
      profile_website
    end
    
    context "setters" do
      before(:each) do
        allow(@bot).to receive(:deprecated)
      end
      [
        {:consumer_secret => :consumer_secret},
        {:consumer_key => :consumer_key},
        {:token => :access_token},
        {:secret => :access_token_secret}
      ].each do |k|
        key = k.keys.first
        value = k[key]

        it "should be able to set #{key}" do
          send(key, "foo")
          expect(@bot.config[value]).to eq("foo")
        end
      end
    end
    
    describe "update_config" do
      it "should pass to bot object" do
        expect(@bot).to receive(:update_config)
        update_config
      end
    end

    describe "since_id" do
      it "should pass to bot object" do
        expect(@bot).to receive(:config).and_return({:since_id => 1234})
        expect(since_id).to eq(1234)
      end

      it "can be set" do
        since_id(1234)
        expect(@bot.config[:since_id]).to eq(1234)
      end
    end

    describe "since_id_reply" do
      it "should pass to bot object" do
        expect(@bot).to receive(:config).and_return({:since_id_reply => 1234})
        expect(since_id_reply).to eq(1234)
      end
    end

  end
end
