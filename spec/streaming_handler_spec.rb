require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::StreamingHandler" do
  let(:bot) { test_bot }
  let(:handler) { StreamingHandler.new(test_bot) }

  def apply_to_handler(&block)
    handler.apply block
  end
  
  it "should set search query" do
    apply_to_handler { search 'foo' }
    expect(handler.filter).to eql('foo')
  end
  
  it "should set tweet_handler" do
    apply_to_handler { replies {'bar'} }
    expect(handler.tweet_handler.call).to eql('bar')
  end

  it "should set favorited_handler" do
    apply_to_handler { favorited {'bar'} }
    expect(handler.favorite_handler.call).to eql('bar')
  end

  it "should set dm_handler" do
    apply_to_handler { direct_message {'bar'} }
    expect(handler.dm_handler.call).to eql('bar')
  end

  it "should set follow_handler" do
    apply_to_handler { followed {'bar'} }
    expect(handler.follow_handler.call).to eql('bar')
  end

  it "should set delete_handler" do
    apply_to_handler { delete {'bar'} }
    expect(handler.delete_handler.call).to eql('bar')
  end

  it "should set friends_handler" do
    apply_to_handler { friends {'bar'} }
    expect(handler.friends_handler.call).to eql('bar')
  end

  it "should pull config from bot" do
    expect(handler.bot).to receive(:config).and_return('config')
    expect(handler.config).to eql('config')
  end
end
