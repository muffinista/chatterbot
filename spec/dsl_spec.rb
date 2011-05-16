require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::DSL" do
  describe "object setup" do
    it "initializes a new Bot object" do
      Chatterbot::Bot.should_receive(:new).and_return(@bot)
      bot
    end
  end
 

  describe "client routines" do
    before(:each) do
      @bot = mock(Chatterbot::Bot)
      Chatterbot::Bot.stub!(:new).and_return(@bot)
    end
  
    it "#blacklist passes along to bot object" do
      @bot.should_receive(:blacklist=).with(["foo"])
      blacklist ["foo"]
    end

    it "#blacklist turns single-string arg into an array" do
      @bot.should_receive(:blacklist=).with(["foo"])
      blacklist "foo"
    end

    it "#blacklist turns comma-delimited string arg into an array" do
      @bot.should_receive(:blacklist=).with(["foo", "bar"])
      blacklist "foo, bar"
    end

    it "#search passes along to bot object" do
      @bot.should_receive(:_search).with("foo")
      search("foo")
    end

    it "#search passes along to bot object" do
      @bot.should_receive(:_search).with(["foo","bar"])
      search(["foo","bar"])
    end
    
    it "#replies passes along to bot object" do
      @bot.should_receive(:_replies)
      replies
    end

    it "#tweet passes along to bot object" do
      @bot.should_receive(:_tweet).with("hello sailor!", {:foo => "bar" }, nil)
      tweet "hello sailor!", {:foo => "bar"}
    end

    it "#reply passes along to bot object" do
      @bot.should_receive(:_tweet).with("hello sailor!", {:foo => "bar" }, { :source => "source "})
      tweet "hello sailor!", {:foo => "bar"}, { :source => "source "}
    end
    
  end
end
