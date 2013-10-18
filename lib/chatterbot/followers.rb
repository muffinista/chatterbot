module Chatterbot
  module Followers
    
    #
    # return a collection of the users followers
    # @todo we should cache this locally
    #
    def followers(opts={})
      return unless require_login
      client.followers(opts).to_a
    end
  end
end
