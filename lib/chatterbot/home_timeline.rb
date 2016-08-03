module Chatterbot

  #
  # methods for checking the bots timeline
  module HomeTimeline

    # handle the bots timeline
    def home_timeline(*args, &block)
      return unless require_login
      debug "check for home_timeline tweets since #{since_id_home_timeline}"

      opts = {
        :since_id => since_id_home_timeline,
        :count => 200
      }
      results = client.home_timeline(opts)

      @current_tweet = nil
      results.each { |s|
        update_since_id_home_timeline(s)
        if block_given? && valid_tweet?(s)
          @current_tweet = s
          yield s         
        end
      }
      @current_tweet = nil
    end
  end
end
