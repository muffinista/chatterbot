require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Client" do
  before(:each) do
    @bot = Chatterbot::Bot.new
    @bot.client = mock(Object)
  end

  describe "reset_since_id" do
    it "runs a search to get a new max_id" do
      bot = test_bot

      bot.stub!(:search_client).and_return(fake_search(100, 1))
      bot.search_client.should_receive(:search).with("a")
      bot.reset_since_id

      bot.config[:tmp_since_id].should == 100
    end
  end
  
  it "runs init_client and login on #require_login" do
    @bot.should_receive(:init_client).and_return(true)
    @bot.should_receive(:login).and_return(true)
    @bot.require_login
  end

  describe "init_client" do
    before(:each) do
      @client = mock(Twitter::Client)
      @bot.should_receive(:client).and_return(@client)
    end

    it "returns true when client has credentials" do
      @client.should_receive(:credentials?).and_return(true)
      @bot.init_client.should == true
    end

    it "returns false when client does not have credentials" do
      @client.should_receive(:credentials?).and_return(false)
      @bot.init_client.should == false
    end
  end


  it "reset_client resets the client instance" do
    @bot.should_receive(:init_client).and_return(true)
    @bot.reset_client
  end
  
  describe "api setup" do
    it "calls get_api_key" do
      @bot.should_receive(:needs_api_key?).and_return(true)
      @bot.should_receive(:needs_auth_token?).and_return(false)
      @bot.should_receive(:get_api_key)
      @bot.login
    end
  end
  
  describe "oauth validation" do
    before(:each) do
      @bot.should_receive(:needs_api_key?).and_return(false)
      @bot.should_receive(:needs_auth_token?).and_return(true)
      @bot.should_receive(:get_oauth_verifier).and_return("pin")
    end

    it "handles getting an auth token" do
      token = mock(Object,
                   :token => "token",
                   :secret => "secret"                                                                
                   )

      @bot.should_receive(:request_token).and_return(token)
      token.should_receive(:get_access_token).with(:oauth_verifier => "pin").
        and_return(mock(:token => "access_token", :secret => "access_secret"))

      @bot.should_receive(:get_screen_name)
      @bot.should_receive(:update_config)
      
      @bot.login

      @bot.config[:token].should == "access_token"
      @bot.config[:secret].should == "access_secret"     
    end

    it "handles errors" do
      @bot.should_receive(:display_oauth_error)
      @bot.login
    end
  end

  describe "get_screen_name" do
    before(:each) do
      @json = '{"id":12345,"screen_name":"mockbot"}'

      @token = mock(Object)
      response = mock(Object, :body => @json)
      @token.should_receive(:get).with("/1/account/verify_credentials.json").and_return(response)
    end

    it "should work" do
      @bot.get_screen_name(@token)
      @bot.screen_name.should == "mockbot"
    end
  end
  


end
