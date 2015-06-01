module Chatterbot

  #
  # methods for only tweeting to users on a specific list
  module Safelist
    attr_accessor :safelist

    alias :whitelist :safelist
    
    # A list of Twitter users that we can communicate with
    def safelist
      @safelist || []
    end

    def safelist=(b)
      @safelist = b
      @safelist = @safelist.flatten.collect { |e|
        (e.is_a?(Twitter::User) ? from_user(e) : e).downcase
      }
      @safelist
    end

    def has_safelist?
      !safelist.empty?
    end

    #
    # Is this tweet from a user on our safelist?
    def on_safelist?(s)
      search = (s.respond_to?(:user) ? from_user(s) : s).downcase
      safelist.any? { |b| search.include?(b.downcase) }
    end
  end
end
