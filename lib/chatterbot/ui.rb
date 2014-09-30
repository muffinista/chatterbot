module Chatterbot
  
  #
  # routines for outputting setup instructions
  #
  module UI

    API_SIGNUP_URL = "https://twitter.com/apps/new"

    
    def red(str)
      puts str.colorize(:red)
    end

    def green(str)
      puts str.colorize(:green)
    end
    
    #
    # print out a message about getting a PIN from twitter, then output
    # the URL the user needs to visit to authorize
    #
    #:nocov:
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
     
      sleep(1)

      puts "Paste your PIN and hit enter when you have completed authorization.\n\n"
      print "> "

      STDIN.readline.chomp
    rescue Interrupt => e
      exit
    end

    #
    # Ask the user to get an API key from Twitter.
    def get_api_key
      green "****************************************"
      green "****************************************"
      green "****        API SETUP TIME!         ****"
      green "****************************************"
      green "****************************************"      

      
      puts "Hey, looks like you need to get an API key from Twitter before you can get started."
      puts "Please hit enter, and I will send you to #{API_SIGNUP_URL} to start the process."
      puts "(If it doesn't work, you can open a browser and paste the URL in manually)"

      puts "\nHit Enter to continue."
      
      STDIN.readline

      Launchy.open(API_SIGNUP_URL)
      # pause to allow any launchy output
      sleep(1)

      puts "\n\n"
      
      print "\n\nPaste the 'API Key' here: "
      STDOUT.flush
      config[:consumer_key] = STDIN.readline.chomp

      print "Paste the 'API Secret' here: "
      STDOUT.flush
      config[:consumer_secret] = STDIN.readline.chomp

      # reset the client so we can re-init with new OAuth credentials
      reset_client
      
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
