
class StreamingHandler
  attr_reader :tweet_handler
  attr_reader :favorite_handler
  attr_reader :dm_handler
  attr_reader :follow_handler
  attr_reader :delete_handler
  attr_reader :friends_handler
  attr_reader :search_filter

  attr_accessor :opts

  def initialize(bot, opts = {})
    @bot = bot
    @opts = opts
  end

  def bot
    @bot
  end
  
  def config
    bot.config
  end

  # filter, firehose, sample, user
  def endpoint
    opts[:endpoint] || :user
  end
  
  def search(query, opts = {}, &block)
    @search_filter = query
    @search_opts = opts
    apply_main_block(&block) if block_given?
  end
  
  def user(&block)
    apply_main_block(&block)
  end
  alias_method :replies, :user
  alias_method :timeline, :user
  alias_method :sample, :user
  alias_method :filter, :user
  
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
  
  def connection_params 
    opts = {
      #:with => 'followings',
      #:replies => false,
      :stall_warnings => false
    }.merge(@opts)
   
    opts.delete(:endpoint)
      
    # convert true/false to strings
    opts.each { |k, v| opts[k] = v.to_s }
    
    if @search_filter
      opts[:track] = @search_filter
    end

    opts
  end  

  def apply_main_block(&block)
    if !@tweet_handler.nil?
      warn "WARNING: when using streaming, you may only have one block of user/replies/timeline/sample/filter"
      raise RuntimeError, 'Unable to load bot'
    end
    @tweet_handler = block
  end
  
  
  def apply(block)
    instance_exec &block
  end
end
