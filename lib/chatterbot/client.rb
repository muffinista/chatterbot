require 'json'
  
module Chatterbot
  
  #
  # routines for connecting to Twitter and validating the bot
  #
  module Client
    attr_accessor :screen_name, :client, :streaming_client

    #
    # the main interface to the Twitter API
    #
    def client
      @client ||= Twitter::REST::Client.new(client_params)
    end

    #
    # interace to the Streaming API
    #
    def streaming_client
      @streaming_client ||= Twitter::Streaming::Client.new(client_params)
    end

    #
    # return the currently authenticated User
    #
    def authenticated_user
      @user ||= client.user
    end

    #
    # reset a few tweet_id trackers
    #
    def reset!
      config[:since_id] = 1
      config[:since_id_reply] = 1
    end

    # reset all since_id counters
    def reset_since_id_counters
      reset!
      reset_since_id
      reset_since_id_reply
      reset_since_id_home_timeline
      reset_since_id_dm
    end
    
    #
    # reset the since_id for this bot to the highest since_id we can
    # get, by running a really open search and updating config with
    # the max_id   
    #
    def reset_since_id
      config[:since_id] = 1
      # do a search of recent tweets with the letter 'a' in them to
      # get a rough max tweet id
      result = client.search("a", since:Time.now - 10).max_by(&:id)
      update_since_id(result)
    end

    #
    # resets the since_id_reply for this bot to the last mention received
    #
    def reset_since_id_reply
      config[:since_id_reply] = 0
      result = client.mentions_timeline.max_by(&:id)
      update_since_id_reply(result)
    end

    #
    # resets the home_timeline_id_reply for this bot to the last tweet
    # on the timeline
    #
    def reset_since_id_home_timeline
      config[:since_id_reply] = 0
      result = client.home_timeline.max_by(&:id)
      update_since_id_home_timeline(result)
    end

    # reset to the last DM received
    def reset_since_id_dm
      config[:since_id_dm] = 0
      result = client.direct_messages_received.max_by(&:id)
      update_since_id_dm(result)
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
      opts[:since_id_reply] = since_id_reply if since_id_reply > 0

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

    # grab a OAuth request token
    def request_token
      @request_token ||= consumer.get_request_token
    end

    #
    # query twitter for the bots screen name. we do this during the bot registration process
    #
    def get_screen_name(t = @access_token)
      return unless @screen_name.nil?
      return if t.nil?

      oauth_response = t.get('/1.1/account/verify_credentials.json')
      @screen_name = JSON.parse(oauth_response.body)["screen_name"]
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
        pin = get_oauth_verifier
        return false if pin.nil?


        begin
          # this will throw an error that we can try and catch
          @access_token = request_token.get_access_token(:oauth_verifier => pin.chomp)
          get_screen_name

          self.config[:access_token] = @access_token.token
          self.config[:access_token_secret] = @access_token.secret

          #update_config unless ! do_update_config
          reset_client

        rescue OAuth::Unauthorized => e
          display_oauth_error
          warn e.inspect
          return false
        end
      end

      return true
    end
  end
end
