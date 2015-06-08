require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Blocklist" do
  before(:each) do
    @bot = test_bot
  end

  it "has a list of excluded phrases" do
    @bot.exclude = ["junk", "i hate bots", "foobar", "spam"]
    expect(@bot.skip_me?("did you know that i hate bots?")).to eq(true)
  end

  describe "skip_me?" do
    before(:each) do
      @bot.exclude = ["junk", "i hate bots", "foobar", "spam"]
    end

    it "blocks tweets with phrases we don't want" do
      expect(@bot.skip_me?("did you know that i hate bots?")).to eq(true)
    end

    it "isn't case-specific" do
      expect(@bot.skip_me?("DID YOU KNOW THAT I HATE BOTS?")).to eq(true)
    end

    it "allows users we do want" do
      expect(@bot.skip_me?("a tweet without any bad content")).to eq(false)
    end

    it "works with Tweet objects" do
      expect(@bot.skip_me?(Twitter::Tweet.new(:id => 1, :text => "did you know that i hate bots?"))).to eq(true)
      expect(@bot.skip_me?(Twitter::Tweet.new(:id => 1, :text => "a tweet without any bad content"))).to eq(false)
    end
  end

  describe "on_blocklist?" do
    before(:each) do
      @bot.blocklist = ["skippy", "blippy", "dippy"]
    end

    it "blocks users we don't want" do
      expect(@bot.on_blocklist?("skippy")).to eq(true)
    end

    it "allows users we do want" do
      expect(@bot.on_blocklist?("flippy")).to eq(false)
    end

    it "isn't case-specific" do
      expect(@bot.on_blocklist?("FLIPPY")).to eq(false)
      expect(@bot.on_blocklist?("SKIPPY")).to eq(true)
    end

    it "works with result hashes" do
      expect(@bot.on_blocklist?(Twitter::Tweet.new(:id => 1,
                                            :user => {:id => 1, :screen_name => "skippy"}))).to eq(true)
      expect(@bot.on_blocklist?(Twitter::Tweet.new(:id => 1,
                                            :user => {:id => 1, :screen_name => "flippy"}))).to eq(false)
    end   

    it "works with users" do
      expect(@bot.on_blocklist?(Twitter::User.new({:id => 1, :name => "skippy"}))).to eql(true)
      expect(@bot.on_blocklist?(Twitter::User.new({:id => 1, :name => "flippy"}))).to eql(false)
    end
  end

  describe "interact_with_user?" do
    before(:each) do
      @user = Twitter::User.new({:id => 1, :name => "flippy"})
    end

    it "is always true if only_interact_with_followers == false" do
      @bot.only_interact_with_followers = false
      expect(@bot.interact_with_user?(@user)).to eql(true)
    end

    context "when only_interact_with_followers == true" do
      before(:each) do
        @bot.only_interact_with_followers = true
        @auth_user = double(Twitter::User)
        allow(@bot).to receive(:authenticated_user).and_return(@auth_user)
      end

      it "is true if follower of account" do
        expect(@bot.client).to receive(:friendship?).with(@user, @auth_user).and_return(true)
        expect(@bot.interact_with_user?(@user)).to eql(true)
      end

      it "is false if not follower of account" do
        expect(@bot.client).to receive(:friendship?).with(@user, @auth_user).and_return(false)
        expect(@bot.interact_with_user?(@user)).to eql(false)
      end   
    end
  end

 
  describe "valid_tweet?" do
    context "with safelist" do
      before(:each) do
        @bot.safelist = ["flippy"]
      end

      it "is true if on safelist" do
        @user = Twitter::User.new({:id => 1, :name => "flippy"})
        expect(@bot.valid_tweet?(@user)).to eql(true)       

        @tweet = Twitter::Tweet.new(:id => 1, :user => {:id => 1, :screen_name => "flippy"})
        expect(@bot.valid_tweet?(@tweet)).to eq(true)
      end

      it "is false if not on safelist" do
        @user = Twitter::User.new({:id => 1, :name => "skippy"})
        expect(@bot.valid_tweet?(@user)).to eql(false)


        @tweet = Twitter::Tweet.new(:id => 1, :user => {:id => 1, :screen_name => "skippy"})
        expect(@bot.valid_tweet?(@tweet)).to eq(false)
      end
    end

    context "without safelist" do
      # !skippable_retweet?(object) &&
      #! on_blocklist?(object) &&
      #! skip_me?(object) &&
      #interact_with_user?(object)
      before(:each) do
        @tweet = Twitter::Tweet.new(:id => 1, :user => {:id => 1, :screen_name => "skippy"})
      end
      
      it "is false if skippable_retweet" do
        allow(@bot).to receive(:skippable_retweet?).with(@tweet).and_return(true)
        expect(@bot.valid_tweet?(@tweet)).to eql(false)
      end

      it "is false if on blocklist" do
        allow(@bot).to receive(:skippable_retweet?).with(@tweet).and_return(false)
        allow(@bot).to receive(:on_blocklist?).with(@tweet).and_return(true)

        expect(@bot.valid_tweet?(@tweet)).to eql(false)
      end

      it "is false if on exclude list" do
        allow(@bot).to receive(:skippable_retweet?).with(@tweet).and_return(false)
        allow(@bot).to receive(:on_blocklist?).with(@tweet).and_return(false)
        allow(@bot).to receive(:skip_me?).with(@tweet).and_return(true)

        expect(@bot.valid_tweet?(@tweet)).to eql(false)
      end
      
      it "is false if ! interact_with_user" do
        allow(@bot).to receive(:skippable_retweet?).with(@tweet).and_return(false)
        allow(@bot).to receive(:on_blocklist?).with(@tweet).and_return(false)
        allow(@bot).to receive(:skip_me?).with(@tweet).and_return(false)
        allow(@bot).to receive(:interact_with_user?).with(@tweet).and_return(false)

        expect(@bot.valid_tweet?(@tweet)).to eql(false)
      end

      it "is true otherwise" do
        allow(@bot).to receive(:skippable_retweet?).with(@tweet).and_return(false)
        allow(@bot).to receive(:on_blocklist?).with(@tweet).and_return(false)
        allow(@bot).to receive(:skip_me?).with(@tweet).and_return(false)
        allow(@bot).to receive(:interact_with_user?).with(@tweet).and_return(true)

        expect(@bot.valid_tweet?(@tweet)).to eql(true)
      end
    end
  end
  
end
