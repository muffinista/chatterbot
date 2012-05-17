module Chatterbot
  
  #
  # routines for connecting to Twitter and validating the bot
  module Client

    # the Twitter client
    #attr_accessor :client

    attr_accessor :screen_name
    attr_accessor :client
    attr_accessor :search_client

    def search_client
      if @search_client
        return @search_client
      end

      @search_client = Twitter::Client.new(
                                    :consumer_key => client_params[:consumer_key],
                                    :consumer_secret => client_params[:consumer_secret],
                                    :oauth_token => client_params[:token],
                                    :oauth_token_secret => client_params[:secret]
                                    )
    end

    def client
      if @client
        return @client
      end

      @client = Twitter::Client.new(
                                    :endpoint => "https://api.twitter.com",
                                    :consumer_key => client_params[:consumer_key],
                                    :consumer_secret => client_params[:consumer_secret],
                                    :oauth_token => client_params[:token],
                                    :oauth_token_secret => client_params[:secret]
                                    )
    end


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
      client.credentials?
    end
    
    #
    # Re-initialize with Twitter, handy during the auth process
    def reset_client
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

    def base_url
      "https://api.twitter.com"
    end

    def consumer
      OAuth::Consumer.new(
                          config[:consumer_key],
                          config[:consumer_secret],
                          :site => base_url
                          )
    end

    def generate_authorize_url(request_token)
      request = consumer.create_signed_request(:get, consumer.authorize_path, request_token, pin_auth_parameters)
      params = request['Authorization'].sub(/^OAuth\s+/, '').split(/,\s+/).map do |param|
        key, value = param.split('=')
        value =~ /"(.*?)"/
        "#{key}=#{CGI::escape($1)}"
      end.join('&')
      "#{base_url}#{request.path}?#{params}"
    end

    def pin_auth_parameters
      {:oauth_callback => 'oob'}
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
        request_token = consumer.get_request_token
        url = generate_authorize_url(request_token)

#        require 'launchy'
#        Launchy.open(url)

        pin = get_oauth_verifier(request_token)

#        pin = ask "Paste in the supplied PIN:"
#        access_token = request_token.get_access_token(:oauth_verifier => pin.chomp)
#        oauth_response = access_token.get('/1/account/verify_credentials.json')
#        screen_name = oauth_response.body.match(/"screen_name"\s*:\s*"(.*?)"/).captures.first


        return false if pin.nil?
        @access_token = request_token.get_access_token(:oauth_verifier => pin.chomp)
        oauth_response = @access_token.get('/1/account/verify_credentials.json')

        @screen_name = oauth_response.body.match(/"screen_name"\s*:\s*"(.*?)"/).captures.first

        config[:token] = @access_token.token
        config[:secret] = @access_token.secret
        update_config unless do_update_config == false
      end

      true
    end
  end
end
