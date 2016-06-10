module Chatterbot
  
  #
  # routines for outputting setup instructions
  #
  module UI
    # Where to send users who need to get API keys
    API_SIGNUP_URL = "https://apps.twitter.com/app/new"

    
    #:nocov:
    def red(str)
      puts str.colorize(:red)
    end

    def green(str)
      puts str.colorize(:green)
    end

    # print out a deprecation notice
    def deprecated(msg, src)
      red(msg)
      green("Called from " + src)
    end
    
    #
    # print out a message about getting a PIN from twitter, then output
    # the URL the user needs to visit to authorize
    #
    def get_oauth_verifier
      green "****************************************"
      green "****************************************"
      green "****        BOT AUTH TIME!          ****"
      green "****************************************"
      green "****************************************"      

      puts "You need to authorize your bot with Twitter.\n\nPlease login to Twitter under the bot's account. When you're ready, hit Enter.\n\nYour browser will open with the following URL, where you can authorize the bot.\n\n"

      url = request_token.authorize_url

      puts url

      puts "\nIf that doesn't work, you can open the URL in your browser manually."

      puts "\n\nHit enter to start.\n\n"
      
      STDIN.readline.chomp
      
      Launchy.open(url)

      # sleep here so that if launchy has any output (which it does
      # sometimes), it doesn't interfere with our input prompt
     
      sleep(2)

      puts "Paste your PIN and hit enter when you have completed authorization.\n\n"
      print "> "

      STDIN.readline.chomp.strip
    rescue Interrupt => e
      exit
    end

    def ask_yes_no(q)
      prompt = "> "
      response = ""


      while ! ["y", "n"].include?(response)
        puts "#{q} [Y/N]"
        print prompt
        response = $stdin.gets.chomp.downcase[0]
      end
      
      if response == "y"
        true
      else
        false
      end
    end

    def send_to_app_creation
      puts "Please hit enter, and I will send you to #{API_SIGNUP_URL} to start the process."
      puts "(If it doesn't work, you can open a browser and paste the URL in manually)"

      puts "\nHit Enter to continue."
      
      STDIN.readline

      Launchy.open(API_SIGNUP_URL)

      # pause to allow any launchy output
      sleep(2)

      puts "\n\n"


      puts "Once you've filled out the app form, click on the 'Keys and Access Tokens' link"
    end
    
    #
    # Ask the user to get an API key from Twitter.
    def get_api_key
      
      green "****************************************"
      green "****************************************"
      green "****        API SETUP TIME!         ****"
      green "****************************************"
      green "****************************************"      


      puts "\n\nWelcome to Chatterbot. Let's walk through the steps to get a bot running.\n\n"


      #
      # At this point, we don't have any API credentials at all for
      # this bot, but it's possible the user has already setup an app.
      # Let's ask!
      #
      
      puts "Hey, looks like you need to get an API key from Twitter before you can get started.\n\n"
      
      app_already_exists = ask_yes_no("Have you already set up an app with Twitter?")

      if app_already_exists
        puts "Terrific! Let's get your bot running!\n\n"
      else
        puts "OK, I can help with that!\n\n"
        send_to_app_creation
      end

      
      print "\n\nPaste the 'Consumer Key' here: "
      STDOUT.flush
      config[:consumer_key] = STDIN.readline.chomp.strip

      print "Paste the 'Consumer Secret' here: "
      STDOUT.flush
      config[:consumer_secret] = STDIN.readline.chomp.strip


      puts "\n\nNow it's time to authorize your bot!\n\n"
      
      if ! app_already_exists && ask_yes_no("Do you want to authorize a bot using the account that created the app?")
        puts "OK, on the app page, you can click the 'Create my access token' button to proceed.\n\n"

        print "Paste the 'Access Token' here: "
        STDOUT.flush
        config[:access_token] = STDIN.readline.chomp.strip


        print "\n\nPaste the 'Access Token Secret' here: "
        STDOUT.flush
        config[:access_token_secret] = STDIN.readline.chomp.strip

      
        # reset the client so we can re-init with new OAuth credentials
        reset_client

        # at this point we should have a fully validated client, so grab
        # the screen name
        @screen_name = client.user.screen_name rescue nil
      else
        reset_client
      end
        
      
      #
      # capture ctrl-c and exit without a stack trace
      #
    rescue Interrupt => e
      exit
    end

    #
    # error message for auth
    def display_oauth_error
      STDERR.puts "Oops!  Looks like something went wrong there, please try again!"
    end
  end
  #:nocov:
end
