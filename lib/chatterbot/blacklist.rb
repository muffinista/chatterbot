module Chatterbot
  module Blacklist

    # def self.included(base)
    #   @exclude = []
    #   @blacklist = []
    #   @global_blacklist = []
    # end

    def exclude=(x)
      @exclude = x
    end
    def exclude
      @exclude || []
    end
   
    def blacklist
      @_blacklist ||= bot_blacklist + load_global_blacklist
    end
   
    def skip_me?(s)
      search = s.is_a?(Hash) ? s["text"] : s
      exclude.detect { |e| search.downcase.include?(e) } != nil
    end

    def on_blacklist?(s)
      search = s.is_a?(Hash) ? s["from_user"] : s     
      blacklist.detect { |b| search.downcase.include?(b.downcase) } != nil
    end

protected
    def bot_blacklist
      @blacklist || []
    end

    def load_global_blacklist
      return [] if ! has_db?
      db[:blacklist].collect{ |x| x[:user] }
    end

  end
end
