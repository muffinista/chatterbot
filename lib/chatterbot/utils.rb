module Chatterbot

  # Assorted handy utility methods
  module Utils

    #
    # return the id of a tweet, or the incoming object (likely already
    # an ID)
    #
    # @param [Tweet] t the Tweet
    def id_from_tweet(t)
      t.is_a?(Twitter::Tweet) ? t.id : t
    end

    #
    # return the id of a User, or the incoming object (likely already
    # an ID)
    #
    # @param [User] u the User
    def id_from_user(u)
      u.is_a?(Twitter::User) ? u.id : u
    end
  end
end
