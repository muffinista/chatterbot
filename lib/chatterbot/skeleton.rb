module Chatterbot

  #
  # bot template generator
  class Skeleton
    class << self
      def generate(bot)
        path = File.join(Chatterbot.libdir, "..", "templates", "skeleton.txt")
        src = File.read(path)

        opts = bot.config.merge({
          :name => bot.botname,
          :timestamp => Time.now
        })

        puts opts.inspect
        
        src % opts
      end
    end
  end
end
