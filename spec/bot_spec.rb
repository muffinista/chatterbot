require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Bot" do
  before(:each) do
    @bot = Chatterbot::Bot.new
  end

  describe "Streaming API" do
    it "should call streaming_client.user" do
      expect(@bot.streaming_client).to receive(:user)
      @bot.stream!
    end
  end

  describe "REST API" do
    it "should work" do
      allow(@bot).to receive(:require_login).and_return(false)
      allow(@bot).to receive(:client).and_return(fake_home_timeline(3))
      @bot.register_handler(:home_timeline) {}
      #@bot.run!
    end
  end

  describe "run_or_stream" do
    it "should use streaming if specified" do
      expect(@bot).to receive(:stream!)
      @bot.streaming = true
      @bot.run_or_stream
    end

    it "should use streaming if required by handler" do
      expect(@bot).to receive(:stream!)
      @bot.register_handler(:deleted) {}
      @bot.run_or_stream
    end

    it "should use REST if specified" do
      expect(@bot).to receive(:run!)
      @bot.run_or_stream
    end
  end


  
  describe "stream!" do
    before(:each) do
      @bot.streaming = true
      @sc = double(Twitter::Client)
      expect(@bot).to receive(:streaming_client).and_return(@sc)
    end

    it "tweaks settings for searches" do
      @bot.register_handler(:search, "hello") {}
      expect(@sc).to receive(:filter)
      @bot.stream!
    end

    it "calls :user for non-searches" do
      @bot.register_handler(:home_timeline) {}
      expect(@sc).to receive(:user)

      @bot.stream!
    end
  end
  
  describe "streamify_search_options" do
    it "works with string" do
      expect( @bot.streamify_search_options("hello there") ).
        to eql({track:"hello there"})


      expect( @bot.streamify_search_options("hello there, friend") ).
        to eql({track:"hello there, friend"})
    end

    it "works with array" do
      expect( @bot.streamify_search_options(["hello there"]) ).
        to eql({track:"hello there"})

      expect( @bot.streamify_search_options(["hello there", "friend"]) ).
        to eql({track:"hello there, friend"})
    end

    it "works with hash" do
      opts = {filter:"hello"}
      expect( @bot.streamify_search_options(opts) ).
        to eql(opts)

    end
  end

end
