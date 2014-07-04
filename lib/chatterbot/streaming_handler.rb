
class StreamingHandler
  attr_reader :tweet_handler
  attr_reader :favorite_handler
  attr_reader :dm_handler
  attr_reader :follow_handler
  attr_reader :delete_handler
  attr_reader :friends_handler
  attr_reader :filter

  attr_accessor :opts

  def initialize(bot)
    @bot = bot
    @opts = {}
  end

  def bot
    @bot
  end
  
  def config
    bot.config
  end

  def search(query) #, opts = {}, &block)
    @filter = query
  end

  def replies(&block)
    @tweet_handler = block
  end

  def favorited(&block)
    @favorite_handler = block
  end
  
  def direct_message(&block)
    @dm_handler = block
  end
  
  def followed(&block)
    @follow_handler = block
  end

  def delete(&block)
    @delete_handler = block
  end

  def friends(&block)
    @friends_handler = block
  end

  def apply(block)
    instance_exec &block
  end
end
