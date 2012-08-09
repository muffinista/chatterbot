module Chatterbot
  
  #
  # routines for outputting setup instructions
  #
  module UI

    #
    # print out a message about getting a PIN from twitter, then output
    # the URL the user needs to visit to authorize
    #
    def get_oauth_verifier
      puts "****************************************"
      puts "****************************************"
      puts "****        BOT AUTH TIME!          ****"
      puts "****************************************"
      puts "****************************************"      

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
      
    end

    #
    # Ask the user to get an API key from Twitter.
    def get_api_key
      puts "****************************************"
      puts "****************************************"
      puts "****        API SETUP TIME!         ****"
      puts "****************************************"
      puts "****************************************"      

      api_url = "https://dev.twitter.com/apps/new"
      
      puts "Hey, looks like you need to get an API key from Twitter before you can get started."
      puts "Please hit enter, and I will send you to #{api_url} to start the process."
      puts "(If it doesn't work, you can open a browser and paste the URL in manually)"

      puts "\nHit Enter to continue."
      
      STDIN.readline

      Launchy.open(api_url)
      # pause to allow any launchy output
      sleep(1)

      puts "\n\n"
      
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
      exit
    end

    #
    # error message for auth
    def display_oauth_error
      STDERR.puts "Oops!  Looks like something went wrong there, please try again!"
    end

  end
end
