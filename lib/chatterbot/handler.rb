module Chatterbot

  #
  # class for holding onto a block/arguments we will use when calling
  # methods on the Twitter API
  #
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

    #
    # call the block with the specified arguments
    #
    def call(*args)
      @block.call(*args)
    end
  end
end
