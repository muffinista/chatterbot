module Chatterbot
  
  #
  # routines for connecting to Twitter and validating the bot
  #
  module Client
    attr_accessor :screen_name, :client, :search_client

    #
    # the main interface to the Twitter API
    #
    def client
      @client ||= Twitter::Client.new(
                                      :endpoint => base_url,
                                      :consumer_key => client_params[:consumer_key],
                                      :consumer_secret => client_params[:consumer_secret],
                                      :oauth_token => client_params[:token],
                                      :oauth_token_secret => client_params[:secret]
                                      )
    end

    #
    # client for running searches -- for some reason Twitter::Client is overwriting
    # the endpoint for searches in a destructive fashion. This takes care of that problem
    #
    def search_client
      return client

      @search_client ||= Twitter::Client.new(
                                      :endpoint => base_url,
                                      :consumer_key => client_params[:consumer_key],
                                      :consumer_secret => client_params[:consumer_secret],
                                      :oauth_token => client_params[:token],
                                      :oauth_token_secret => client_params[:secret]
                                      )
    end


    #
    # the URL we should use for api calls
    #
    def base_url
      "https://api.twitter.com"
    end


    #
    # default options when querying twitter -- this could be extended
    # with a language, etc.
    def default_opts
      opts = {
        :result_type => "recent"
      }
      opts[:since_id] = since_id if since_id > 0

      opts
    end
    

    #
    # Initialize the Twitter client, and check to see if it has credentials or not
    # @return true/false depending on if client has OAuth credentials
    def init_client
      client.credentials?
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
    def get_oauth_verifier
      #url = generate_authorize_url(request_token)

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

      # reset the client so we can re-init with new OAuth credentials
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
      STDERR.puts "Oops!  Looks like something went wrong there, please try again!"
    end


    #
    # simple OAuth client for setting up with Twitter
    #
    def consumer
      @consumer ||= OAuth::Consumer.new(
                          config[:consumer_key],
                          config[:consumer_secret],
                          :site => base_url
                          )
    end

    #
    # copied from t, the awesome twitter cli app
    # @see https://github.com/sferik/t/blob/master/lib/t/authorizable.rb
    #
    def generate_authorize_url(request_token)
      request = consumer.create_signed_request(:get,
        consumer.authorize_path, request_token,
        {:oauth_callback => 'oob'})

      params = request['Authorization'].sub(/^OAuth\s+/, '').split(/,\s+/).map do |param|
        key, value = param.split('=')
        value =~ /"(.*?)"/
        "#{key}=#{CGI::escape($1)}"
      end.join('&')

      "#{base_url}#{request.path}?#{params}"
    end

    def request_token
      @request_token ||= consumer.get_request_token
    end

    #
    # query twitter for the bots screen name. we do this during the bot registration process
    #
    def get_screen_name
      return unless @screen_name.nil?

      oauth_response = @access_token.get('/1/account/verify_credentials.json')
      @screen_name = JSON.parse(oauth_response.body)["screen_name"]

#      @screen_name = oauth_response.body.match(/"screen_name"\s*:\s*"(.*?)"/).captures.first
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
        pin = get_oauth_verifier #(request_token)
        return false if pin.nil?


        begin
          # this will throw an error that we can try and catch
          @access_token = request_token.get_access_token(:oauth_verifier => pin.chomp)
          get_screen_name

          config[:token] = @access_token.token
          config[:secret] = @access_token.secret

          update_config unless ! do_update_config
          reset_client

        rescue OAuth::Unauthorized => e
          display_oauth_error
          return false
        end
      end

      return true
    end
  end
end
