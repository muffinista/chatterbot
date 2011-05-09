module Chatterbot
  module Client

    def client=(x)
      @@client = x
    end
    def client
      @@client
    end   

    def default_opts
      {
        :since_id => since_id
      }
    end
    
    
    def init_client
      @@client = TwitterOAuth::Client.new(client_params)
    end

    def require_login
      init_client
      login
    end
    
    #
    # handle oauth for this request.  if the client isn't authorized, print
    # out the auth URL and get a pin code back from the user
    #
    def login
      if needs_auth_token?
        request_token = client.request_token

        puts "#{request_token.authorize_url}\n"
        puts "Paste your PIN and hit enter when you have completed authorization."
        pin = STDIN.readline.chomp

        access_token = client.authorize(
                                         request_token.token,
                                         request_token.secret,
                                         :oauth_verifier => pin
                                         )

        if client.authorized?
          config[:token] = access_token.token
          config[:secret] = access_token.secret
          update_config
        else
          debug "OOPS"
          exit
        end
      end
      true
    end
  end
end
