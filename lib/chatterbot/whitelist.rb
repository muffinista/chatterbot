module Chatterbot

  #
  # methods for only tweeting to users on a specific list
  module Whitelist
    attr_accessor :whitelist
    
    # A list of Twitter users that we can communicate with
    def whitelist
      @whitelist || []
    end

    def whitelist=(b)
      @whitelist = b
      @whitelist = @whitelist.flatten.collect { |e|
        (e.is_a?(Twitter::User) ? from_user(e) : e).downcase
      }
      @whitelist
    end

    def has_whitelist?
      !whitelist.empty?
    end

    #
    # Is this tweet from a user on our whitelist?
    def on_whitelist?(s)
      search = (s.respond_to?(:user) ? from_user(s) : s).downcase
      whitelist.any? { |b| search.include?(b.downcase) }
    end
  end
end
