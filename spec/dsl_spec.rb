require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::DSL" do
  describe "client routines" do
    before(:each) do
      @bot = mock(Chatterbot::Bot)
      @bot.send :require, 'chatterbot/dsl'

      Chatterbot::DSL.stub!(:bot).and_return(@bot)
    end
  
    describe "blacklist" do
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
    end
  
    describe "exclude" do
      it "#exclude passes along to bot object" do
        @bot.should_receive(:exclude=).with(["foo"])
        exclude ["foo"]
      end

      it "#exclude turns single-string arg into an array" do
        @bot.should_receive(:exclude=).with(["foo"])
        exclude "foo"
      end

      it "#exclude turns comma-delimited string arg into an array" do
        @bot.should_receive(:exclude=).with(["foo", "bar"])
        exclude "foo, bar"
      end
    end
    
    
    it "#search passes along to bot object" do
      @bot.should_receive(:search).with("foo", { })
      search("foo")
    end

    it "#search passes along to bot object" do
      @bot.should_receive(:search).with(["foo","bar"], { })
      search(["foo","bar"])
    end
    
    it "#replies passes along to bot object" do
      @bot.should_receive(:replies)
      replies
    end

    it "#tweet passes along to bot object" do
      @bot.should_receive(:tweet).with("hello sailor!", {:foo => "bar" }, nil)
      tweet "hello sailor!", {:foo => "bar"}
    end

    it "#reply passes along to bot object" do
      @bot.should_receive(:reply).with("hello sailor!", { :source => "source "})
      reply "hello sailor!", { :source => "source "}
    end
    
  end
end
