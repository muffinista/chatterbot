module Chatterbot

  # routines for managing your profile
  module Profile

    #
    # get/set the profile description
    #
    def profile_text(p=nil)
      return if require_login == false

      if p.nil?
        client.user.description
      else
        data = {
          description: p
        }
        client.update_profile(data)
        p
      end
    end

    #
    # get/set the profile URL
    #
    def profile_website(w=nil)
      return if require_login == false

      if w.nil?
        client.user.website
      else
        data = {
          url: w
        }
        client.update_profile(data)
        w
      end
    end
  end
end
