module Chatterbot

  #
  # routines for connecting to Twitter and validating the bot
  module Client

    # the Twitter client
    attr_accessor :client

    #
    # default options when querying twitter -- this could be extended
    # with a language, etc.
    def default_opts
      {
        :since_id => since_id
      }
    end
    

    #
    # Initialize the Twitter client
    def init_client
      @client ||= TwitterOAuth::Client.new(client_params)
    end

    #
    # Call this before doing anything that requires an authorized Twitter
    # connection.
    def require_login
      init_client
      login
    end

    #
    # print out a message about getting a PIN from twitter, then output
    # the URL the user needs to visit to authorize
    #
    def get_oauth_verifier
      puts "Please go to the following URL and authorize the bot.\n"        
      puts "#{request_token.authorize_url}\n"

      puts "Paste your PIN and hit enter when you have completed authorization."
      STDIN.readline.chomp
    end

    #
    # error message for auth
    def display_oauth_error
      debug "Oops!  Looks like something went wrong there, please try again!"
      exit
    end
    
    #
    # handle oauth for this request.  if the client isn't authorized, print
    # out the auth URL and get a pin code back from the user
    def login
      if needs_auth_token?
        pin = get_oauth_verifier
        request_token = client.request_token
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
          display_oauth_error
        end
      end
    end
  end
end
