require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Client" do
  before(:each) do
    @bot = Chatterbot::Bot.new
  end

  it "should initialize client" do
    expect(@bot.client).to be_a(Twitter::REST::Client)
  end
  it "should initialize streaming client" do
    expect(@bot.streaming_client).to be_a(Twitter::Streaming::Client)
  end

  describe "reset!" do
    it "should reset a bunch of stuff" do
      @bot.config[:since_id] = 1234
      @bot.config[:since_id_reply] = 1234

      @bot.reset!

      expect(@bot.config[:since_id]).to eql(1)
      expect(@bot.config[:since_id_reply]).to eql(1)
    end
  end
  
  describe "reset_since_id_counters" do
    it "should reset a bunch of stuff" do
      expect(@bot).to receive(:reset!)
      expect(@bot).to receive(:reset_since_id)
      expect(@bot).to receive(:reset_since_id_reply)
      expect(@bot).to receive(:reset_since_id_home_timeline)
      expect(@bot).to receive(:reset_since_id_dm)

      @bot.reset_since_id_counters
    end
  end
  
  describe "reset_since_id" do
    it "runs a search to get a new max_id" do
      bot = test_bot

      allow(bot).to receive(:client).and_return(fake_search(100, 1))
      expect(bot.client).to receive(:search).with("a", anything)
      bot.reset_since_id

      expect(bot.config[:since_id]).to eq(100)
    end
  end

  describe "reset_since_id_reply" do
    it "gets the id of the last reply" do
      bot = test_bot
      allow(bot).to receive(:client).and_return(fake_replies(1, 1000))
      expect(bot.client).to receive(:mentions_timeline)

      bot.reset_since_id_reply

      expect(bot.config[:since_id_reply]).to eq(1000)
    end
  end

  describe "reset_since_id_home_timeline" do
    it "gets the id of the last tweet in timeline" do
      bot = test_bot
      allow(bot).to receive(:client).and_return(fake_home_timeline(3))

      bot.reset_since_id_home_timeline

      expect(bot.config[:since_id_home_timeline]).to eq(3)
    end
  end

  describe "reset_since_id_dm" do
    it "gets the id of the last direct message" do
      bot = test_bot
      allow(bot).to receive(:client).and_return(fake_direct_messages(3))

      bot.reset_since_id_dm

      expect(bot.config[:since_id_dm]).to eq(3)
    end
  end

  
  it "runs init_client and login on #require_login" do
    expect(@bot).to receive(:init_client).and_return(true)
    expect(@bot).to receive(:login).and_return(true)
    @bot.require_login
  end

  describe "init_client" do
    before(:each) do
      @client = double(Twitter::Client)
      expect(@bot).to receive(:client).and_return(@client)
    end

    it "returns true when client has credentials" do
      expect(@client).to receive(:credentials?).and_return(true)
      expect(@bot.init_client).to eq(true)
    end

    it "returns false when client does not have credentials" do
      expect(@client).to receive(:credentials?).and_return(false)
      expect(@bot.init_client).to eq(false)
    end
  end


  it "reset_client resets the client instance" do
    expect(@bot).to receive(:init_client).and_return(true)
    @bot.reset_client
  end
  
  describe "api setup" do
    it "calls get_api_key" do
      expect(@bot).to receive(:needs_api_key?).and_return(true)
      expect(@bot).to receive(:needs_auth_token?).and_return(false)
      expect(@bot).to receive(:get_api_key)
      @bot.login
    end
  end
  
  describe "oauth validation" do
    before(:each) do
      expect(@bot).to receive(:needs_api_key?).and_return(false)
      expect(@bot).to receive(:needs_auth_token?).and_return(true)
      expect(@bot).to receive(:get_oauth_verifier).and_return("pin")
    end

    it "handles getting an auth token" do
      token = double(Object,
                   :token => "token",
                   :secret => "secret"                                                                
                   )

      expect(@bot).to receive(:request_token).and_return(token)
      expect(token).to receive(:get_access_token).with(:oauth_verifier => "pin").
        and_return(double(:token => "access_token", :secret => "access_secret"))

      expect(@bot).to receive(:get_screen_name)
      
      @bot.login

      expect(@bot.config[:access_token]).to eq("access_token")
      expect(@bot.config[:access_token_secret]).to eq("access_secret")     
    end

    it "handles errors" do
      expect(@bot).to receive(:display_oauth_error)
      @bot.login
    end
  end

  describe "get_screen_name" do
    before(:each) do
      @json = '{"id":12345,"screen_name":"bot"}'

      @token = double(Object)
      response = double(Object, :body => @json)
      expect(@token).to receive(:get).with("/1.1/account/verify_credentials.json").and_return(response)
    end

    it "should work" do
      @bot.get_screen_name(@token)
      expect(@bot.screen_name).to eq("bot")
    end
  end
  
  describe "authenticated_user" do
    let(:bot) { test_bot }
    it "should get user from client" do
      expect(bot.client).to receive(:user).and_return('user')
      expect(bot.authenticated_user).to eql('user')
    end
  end


end
