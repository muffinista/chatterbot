module Chatterbot

  #
  # methods for checking the bots timeline
  module HomeTimeline

    # handle the bots timeline
    def home_timeline(opts={}, &block)
      return unless require_login

      debug "check for home_timeline tweets since #{since_id}"

      opts = {
        :since_id => since_id,
        :count => 200
      }.merge(opts)

      results = client.home_timeline(opts)

      @current_tweet = nil
      results.each { |s|
        update_since_id(s)
        if has_whitelist? && !on_whitelist?(s)
          debug "skipping because user not on whitelist"
        elsif block_given? && !on_blacklist?(s) && !skip_me?(s)
          @current_tweet = s
          yield s         
        end
      }
      @current_tweet = nil
    end
  end
end
