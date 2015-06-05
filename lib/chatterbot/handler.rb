module Chatterbot
  class Handler
    attr_reader :opts
    def initialize(opts, &block)
      if block_given?
        @opts = *opts
        @block = block
      else
        @opts = nil
        @block = opts
      end
    end

    def call(*args)
      @block.call(*args)
    end
  end
end
