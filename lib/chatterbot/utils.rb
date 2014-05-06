module Chatterbot
  module Utils
    def id_from_tweet(t)
      t.is_a?(Twitter::Tweet) ? t.id : t
    end

    def id_from_user(u)
      u.is_a?(Twitter::User) ? u.id : u
    end
  end
end
