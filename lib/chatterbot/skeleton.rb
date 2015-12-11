module Chatterbot

  #
  # bot template generator
  class Skeleton
    class << self

      #
      # generate a template file for the specified bot
      # @param [Bot] bot object
      #
      def generate(bot)
        path = File.join(Chatterbot.libdir, "..", "templates", "skeleton.txt")
        src = File.read(path)

        opts = bot.config.to_h.merge({
          :name => bot.botname,
          :timestamp => Time.now
        })

        puts opts.inspect
        
        src % opts
      end
    end
  end
end
