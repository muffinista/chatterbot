require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Blacklist" do
  it "has a list of excluded phrases" do
    @bot = test_bot
    @bot.exclude = ["junk", "i hate bots", "foobar", "spam"]
    @bot.skip_me?("did you know that i hate bots?").should == true
  end

  describe "skip_me?" do
    before(:each) do
      @bot = test_bot
      @bot.stub!(:exclude).and_return(["junk", "i hate bots", "foobar", "spam"])
    end

    it "blocks tweets with phrases we don't want" do
      @bot.skip_me?("did you know that i hate bots?").should == true
    end

    it "isn't case-specific" do
      @bot.skip_me?("DID YOU KNOW THAT I HATE BOTS?").should == true
    end


    it "allows users we do want" do
      @bot.skip_me?("a tweet without any bad content").should == false
    end

    it "works with result hashes" do
      @bot.skip_me?(Twitter::Tweet.new(:id => 1, :text => "did you know that i hate bots?")).should == true
      @bot.skip_me?(Twitter::Tweet.new(:id => 1, :text => "a tweet without any bad content")).should == false
    end
  end

  describe "on_blacklist?" do
    before(:each) do
      @bot = test_bot
      @bot.stub!(:blacklist).and_return(["skippy", "blippy", "dippy"])
    end

    it "blocks users we don't want" do
      @bot.on_blacklist?("skippy").should == true
    end

    it "allows users we do want" do
      @bot.on_blacklist?("flippy").should == false
    end

    it "isn't case-specific" do
      @bot.on_blacklist?("FLIPPY").should == false
      @bot.on_blacklist?("SKIPPY").should == true
    end

    it "works with result hashes" do
      @bot.on_blacklist?(Twitter::Tweet.new(:id => 1, :from_user => "skippy")).should == true
      @bot.on_blacklist?(Twitter::Tweet.new(:id => 1, :from_user => "flippy")).should == false
    end   
  end

  describe "on_global_blacklist?" do
    before(:each) do
      @bot = test_bot
    end

    it "doesn't freak out if no db" do
      @bot.should_receive(:has_db?).and_return(false)
      @bot.on_global_blacklist?("foobar").should == false
    end

    it "collects name from the db if it exists" do
      @bot.stub!(:has_db?).and_return(true)
      blacklist_table = mock(Object)
      mock_dataset = mock(Object, {:count => 1})
      blacklist_table.should_receive(:where).
        with({ :user => "a"}).
        and_return( mock_dataset )

      
      missing_dataset = mock(Object, {:count => 0})
      blacklist_table.should_receive(:where).
        with({ :user => "b"}).
        and_return( missing_dataset )
      
      @bot.stub!(:db).and_return({ 
                                   :blacklist => blacklist_table
                                 })
      @bot.on_global_blacklist?("a").should == true
      @bot.on_global_blacklist?("b").should == false
    end
  end


  describe "db interaction" do
    before(:each) do
      @db_tmp = Tempfile.new("blacklist.db")
      @db_uri = "sqlite://#{@db_tmp.path}"

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
