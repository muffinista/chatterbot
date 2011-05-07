module Botter
  module Blacklist
    
    def exclude=(x)
      @@exclude = x
    end
    def exclude
      @@exclude
    end
    
    def self.included(base)
      @@exclude = []
      @@blacklist = []
      @@global_blacklist = []

      @@total_blacklist = (@@blacklist + @@global_blacklist)    
    end
    
    def skip_me?(s)
      search = s.is_a?(Hash) ? s["text"] : s
      exclude.detect { |e| s.downcase.include?(e) } != nil
    end

    def on_blacklist?(s)
      search = s.is_a?(Hash) ? s["from_user"] : s     
      @@total_blacklist.detect { |b| search.downcase.include?(b.downcase) } != nil
    end
  end
end
