require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::DSL" do
  describe "client routines" do
    before(:each) do
      @bot = double(Chatterbot::Bot, :config => {})
      @bot.send :require, 'chatterbot/dsl'

      allow(Chatterbot::DSL).to receive(:bot).and_return(@bot)
    end

    describe "client" do
      it "returns the bot object" do
        expect(client).to eql(@bot.client)
      end
    end

    describe "blacklist" do
      it "#blacklist passes along to bot object" do
        expect(@bot).to receive(:blacklist=).with(["foo"])
        blacklist ["foo"]
      end

      it "#blacklist turns single-string arg into an array" do
        expect(@bot).to receive(:blacklist=).with(["foo"])
        blacklist "foo"
      end

      it "#blacklist turns comma-delimited string arg into an array" do
        expect(@bot).to receive(:blacklist=).with(["foo", "bar"])
        blacklist "foo, bar"
      end
    end

    describe "whitelist" do
      it "#whitelist passes along to bot object" do
        expect(@bot).to receive(:whitelist=).with(["foo"])
        whitelist ["foo"]
      end

      it "#whitelist turns single-string arg into an array" do
        expect(@bot).to receive(:whitelist=).with(["foo"])
        whitelist "foo"
      end

      it "#whitelist turns comma-delimited string arg into an array" do
        expect(@bot).to receive(:whitelist=).with(["foo", "bar"])
        whitelist "foo, bar"
      end
    end

    describe "only_interact_with_followers" do
      it "sets whitelist to be the bot's followers" do
        f = fake_follower
        allow(@bot).to receive(:followers).and_return([f])
        expect(@bot).to receive(:whitelist=).with([f])
        only_interact_with_followers
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
        expect(@bot).to receive(:search).with("foo", { })
        search("foo")
      end

      it "passes multiple queries along to bot object" do
        expect(@bot).to receive(:search).with(["foo","bar"], { })
        search(["foo","bar"])
      end
    end

    describe "streaming" do
      it "passes along to bot object" do
        expect(@bot).to receive(:do_streaming)
        streaming {}
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
      expect(@bot).to receive(:replies)
      replies
    end
    
    it "#home_timeline passes along to bot object" do
      expect(@bot).to receive(:home_timeline)
      home_timeline
    end

    it "#streaming_tweets passes along to bot object" do
      expect(@bot).to receive(:streaming_tweets)
      streaming_tweets
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
      expect(@bot).to receive(:reply).with("hello sailor!", { :source => "source "})
      reply "hello sailor!", { :source => "source "}
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
      [:consumer_secret, :consumer_key, :token, :secret].each do |k|
        it "should be able to set #{k}" do
          send(k, "foo")
          expect(@bot.config[k]).to eq("foo")
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

    describe "db" do
      it "should pass to bot object" do
        bot_db = double(Object)
        expect(@bot).to receive(:db).and_return(bot_db)

        expect(db).to eql(bot_db)
      end
    end

  end
end
