require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Client" do
  before(:each) do
    @bot = Chatterbot::Bot.new
    @bot.client = mock(Object)
  end

  it "runs init_client and login on #require_login" do
    @bot.should_receive(:init_client).and_return(true)
    @bot.should_receive(:login).and_return(true)
    @bot.require_login
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
      @bot.client.should_receive(:request_token).and_return(
                                                            mock(:token => "token",
                                                                 :secret => "secret"
                                                                 )
                                                            )
      @bot.client.should_receive(:authorize).
        with("token", "secret", { :oauth_verifier => "pin"}).
        and_return(mock(:token => "access_token", :secret => "access_secret"))
    end

    it "handles getting an auth token" do
      @bot.client.should_receive(:authorized?).and_return(true)
      @bot.should_receive(:update_config)
      
      @bot.login

      @bot.config[:token].should == "access_token"
      @bot.config[:secret].should == "access_secret"     
    end

    it "handles errors" do
      @bot.client.should_receive(:authorized?).and_return(false)
      @bot.should_receive(:display_oauth_error)
      @bot.login
    end
  end
end
