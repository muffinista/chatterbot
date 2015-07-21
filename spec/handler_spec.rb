require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Handler" do
  it "accepts a block" do
    @foo = nil
    h = Chatterbot::Handler.new({}) do |_|
      @foo = "bar"
    end

    h.call

    expect(@foo).to eql("bar")
  end

  it "accepts a proc/etc directly" do
    @foo = nil
    @proc = Proc.new do |_|
      @foo = "bar"
    end

    h = Chatterbot::Handler.new(@proc)
    h.call

    expect(@foo).to eql("bar")

  end
end
