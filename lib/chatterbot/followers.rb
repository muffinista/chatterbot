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

    #
    # follow a user
    #
    # @param u a Twitter::User or user id
    def follow(u)
      return unless require_login
      client.follow(u)
    end
  end
end
