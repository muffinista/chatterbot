require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Blocklist" do
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

  describe "on_blocklist?" do
    before(:each) do
      @bot = test_bot
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
  end

  describe "on_global_blocklist?" do
    before(:each) do
      @bot = test_bot
    end

    it "doesn't freak out if no db" do
      expect(@bot).to receive(:has_db?).and_return(false)
      expect(@bot.on_global_blocklist?("foobar")).to eq(false)
    end

    it "collects name from the db if it exists" do
      allow(@bot).to receive(:has_db?).and_return(true)
      blocklist_table = double(Object)
      double_dataset = double(Object, {:count => 1})
      expect(blocklist_table).to receive(:where).
        with({ :user => "a"}).
        and_return( double_dataset )

      
      missing_dataset = double(Object, {:count => 0})
      expect(blocklist_table).to receive(:where).
        with({ :user => "b"}).
        and_return( missing_dataset )
      
      allow(@bot).to receive(:db).and_return({ 
                                   :blocklist => blocklist_table
                                 })
      expect(@bot.on_global_blocklist?("a")).to eq(true)
      expect(@bot.on_global_blocklist?("b")).to eq(false)
    end
  end


  describe "db interaction" do
    before(:each) do
#      @db_tmp = Tempfile.new("blocklist.db")
      @db_uri = "sqlite:/"

      @bot = Chatterbot::Bot.new    
      @bot.config[:db_uri] = @db_uri
      @bot.db
    end

    describe "add_to_blocklist" do
      it "adds to the blocklist table" do      
        @bot.add_to_blocklist("tester")
      end

      it "doesn't add a double entry" do
        @bot.add_to_blocklist("tester")
        @bot.add_to_blocklist("tester")      
      end
    end
    
  end
end
