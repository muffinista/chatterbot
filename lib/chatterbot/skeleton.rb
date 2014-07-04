module Chatterbot

  #
  # bot template generator
  class Skeleton
    class << self
      def generate(bot)
        path = File.join(Chatterbot.libdir, "..", "templates", "skeleton.txt")
        src = File.read(path)
        puts bot.config.inspect
        opts = bot.config.merge({
          :name => bot.botname,
          :timestamp => Time.now
        })

        puts opts.inspect
        
        if RUBY_VERSION =~ /^1\.8\./
          #:nocov:
          apply_vars(src, opts)
          #:nocov:

        else
          src % opts
        end
      end

      #
      # handle string interpolation in ruby 1.8. modified from
      # https://raw.github.com/svenfuchs/i18n/master/lib/i18n/core_ext/string/interpolate.rb
      #
      #:nocov:
      def apply_vars(s, args)
        pattern = Regexp.union(
                                             /%\{(\w+)\}/,                               # matches placeholders like "%{foo}"
                                             /%<(\w+)>(.*?\d*\.?\d*[bBdiouxXeEfgGcps])/  # matches placeholders like "%<foo>.d"
                                             )
        
        pattern_with_escape = Regexp.union(
                                                         /%%/,
                                                         pattern
                                                         )
        
        s.gsub(pattern_with_escape) do |match|
          if match == '%%'
            '%'
          else
            key = ($1 || $2).to_sym
            raise KeyError unless args.has_key?(key)
            $3 ? sprintf("%#{$3}", args[key]) : args[key]
          end
        end
      end
      #:nocov:

    end
  end
end
