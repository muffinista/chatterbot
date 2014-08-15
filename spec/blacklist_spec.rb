require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Blacklist" do
  it "has a list of excluded phrases" do
    @bot = test_bot
    @bot.exclude = ["junk", "i hate bots", "foobar", "spam"]
    expect(@bot.skip_me?("did you know that i hate bots?")).to eq(true)
  end

  describe "skip_me?" do
    before(:each) do
      @bot = test_bot
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

    it "works with result hashes" do
      expect(@bot.skip_me?(Twitter::Tweet.new(:id => 1, :text => "did you know that i hate bots?"))).to eq(true)
      expect(@bot.skip_me?(Twitter::Tweet.new(:id => 1, :text => "a tweet without any bad content"))).to eq(false)
    end
  end

  describe "on_blacklist?" do
    before(:each) do
      @bot = test_bot
      @bot.blacklist = ["skippy", "blippy", "dippy"]
    end

    it "blocks users we don't want" do
      expect(@bot.on_blacklist?("skippy")).to eq(true)
    end

    it "allows users we do want" do
      expect(@bot.on_blacklist?("flippy")).to eq(false)
    end

    it "isn't case-specific" do
      expect(@bot.on_blacklist?("FLIPPY")).to eq(false)
      expect(@bot.on_blacklist?("SKIPPY")).to eq(true)
    end

    it "works with result hashes" do
      expect(@bot.on_blacklist?(Twitter::Tweet.new(:id => 1,
                                            :user => {:id => 1, :screen_name => "skippy"}))).to eq(true)
      expect(@bot.on_blacklist?(Twitter::Tweet.new(:id => 1,
                                            :user => {:id => 1, :screen_name => "flippy"}))).to eq(false)
    end   
  end

  describe "on_global_blacklist?" do
    before(:each) do
      @bot = test_bot
    end

    it "doesn't freak out if no db" do
      expect(@bot).to receive(:has_db?).and_return(false)
      expect(@bot.on_global_blacklist?("foobar")).to eq(false)
    end

    it "collects name from the db if it exists" do
      allow(@bot).to receive(:has_db?).and_return(true)
      blacklist_table = double(Object)
      double_dataset = double(Object, {:count => 1})
      expect(blacklist_table).to receive(:where).
        with({ :user => "a"}).
        and_return( double_dataset )

      
      missing_dataset = double(Object, {:count => 0})
      expect(blacklist_table).to receive(:where).
        with({ :user => "b"}).
        and_return( missing_dataset )
      
      allow(@bot).to receive(:db).and_return({ 
                                   :blacklist => blacklist_table
                                 })
      expect(@bot.on_global_blacklist?("a")).to eq(true)
      expect(@bot.on_global_blacklist?("b")).to eq(false)
    end
  end


  describe "db interaction" do
    before(:each) do
#      @db_tmp = Tempfile.new("blacklist.db")
      @db_uri = "sqlite:/"

      @bot = Chatterbot::Bot.new    
      @bot.config[:db_uri] = @db_uri
      @bot.db
    end

    describe "add_to_blacklist" do
      it "adds to the blacklist table" do      
        @bot.add_to_blacklist("tester")
      end

      it "doesn't add a double entry" do
        @bot.add_to_blacklist("tester")
        @bot.add_to_blacklist("tester")      
      end
    end
    
  end
end
