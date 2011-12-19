module Chatterbot
  
  #
  # routines for connecting to Twitter and validating the bot
  module Client

    # the Twitter client
    attr_accessor :client

    # track the access token so we can get screen name when
    # registering new bots
    attr_accessor :access_token

    #
    # default options when querying twitter -- this could be extended
    # with a language, etc.
    def default_opts
      return {} if since_id <= 0
      {
        :since_id => since_id,
        :result_type => "recent"
      }
    end
    

    #
    # Initialize the Twitter client
    def init_client
      @client ||= TwitterOAuth::Client.new(client_params)
    end
    
    #
    # Re-initialize with Twitter, handy during the auth process
    def reset_client
      @client = nil
      init_client
    end
    
    #
    # Call this before doing anything that requires an authorized Twitter
    # connection.
    def require_login(do_update_config=true)
      init_client
      login(do_update_config)
    end

    #
    # print out a message about getting a PIN from twitter, then output
    # the URL the user needs to visit to authorize
    #
    def get_oauth_verifier(request_token)
      puts "Please go to the following URL and authorize the bot.\n"        
      puts "#{request_token.authorize_url}\n"

      puts "Paste your PIN and hit enter when you have completed authorization."
      STDIN.readline.chomp
    rescue Interrupt => e

    end

    #
    # Ask the user to get an API key from Twitter.
    def get_api_key
      puts "****************************************"
      puts "****************************************"
      puts "****        API SETUP TIME!         ****"
      puts "****************************************"
      puts "****************************************"      
      
      puts "Hey, looks like you need to get an API key from Twitter before you can get started."
      puts "Please go to this URL: https://twitter.com/apps/new"

      print "\n\nPaste the 'Consumer Key' here: "
      STDOUT.flush
      config[:consumer_key] = STDIN.readline.chomp

      print "Paste the 'Consumer Secret' here: "
      STDOUT.flush
      config[:consumer_secret] = STDIN.readline.chomp
      
      reset_client
      
      #
      # capture ctrl-c and exit without a stack trace
      #
    rescue Interrupt => e
#      exit
    end

    #
    # error message for auth
    def display_oauth_error
      debug "Oops!  Looks like something went wrong there, please try again!"
    end
    
    #
    # handle oauth for this request.  if the client isn't authorized, print
    # out the auth URL and get a pin code back from the user
    # If +do_update_config+ is false, don't udpate the bots config
    # file after authorization. This defaults to true but
    # chatterbot-register will pass in false because it does some
    # other work before saving.
    def login(do_update_config=true)
      if needs_api_key?
        get_api_key
      end

      if needs_auth_token?
        request_token = client.request_token

        pin = get_oauth_verifier(request_token)
        return false if pin.nil?

        @access_token = client.authorize(
                                         request_token.token,
                                         request_token.secret,
                                         :oauth_verifier => pin
                                         )


        if client.authorized?
          config[:token] = @access_token.token
          config[:secret] = @access_token.secret

          update_config unless do_update_config == false
        else
          display_oauth_error
          return false
        end
      end

      true
    end
  end
end
