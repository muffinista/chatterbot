module Botter
  module Reply
    
    def _replies(&block)
      return unless require_login
      debug "check for replies since #{since_id}"
      
      replies = client.replies(:since_id => since_id)

      if replies != nil
        replies.each { |s|
          unless !block_given? || on_blacklist?(s) || skip_me?(s)
            update_since_id(s)
            yield s         
          end
        }
      end
    end

  end
end
