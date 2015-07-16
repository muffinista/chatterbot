require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'tempfile'

describe "Chatterbot::ConfigManager" do
  before(:each) do
    @tmp_config_dest = "/tmp/bot.yml"
    @config = Chatterbot::ConfigManager.new(@tmp_config_dest, {:consumer_key => "bar"})
  end
  after(:each) do
    if File.exist?(@tmp_config_dest)
      File.unlink(@tmp_config_dest)
    end
  end

  describe "delete" do
    it "deletes a key" do
      expect(@config.delete(:baz)).to be_nil
    end

    it "works with missing key" do

    end

    it "retains read-only data" do
      expect(@config[:consumer_key]).to eql("bar")
      expect(@config.delete(:consumer_key)).to be_nil
      expect(@config[:consumer_key]).to eql("bar")
    end
  end

  describe "[]=" do
    it "writes a key" do
      expect(@config[:baz]).to be_nil
      @config[:baz] = "hello"
      expect(@config[:baz]).to eql("hello")
    end

    it "does not overwrite read-only data" do
      expect(@config[:consumer_key]).to eql("bar")
      @config[:consumer_key] = "baz"
      expect(@config[:consumer_key]).to eql("bar")
    end
  end

  describe "[]" do
    it "works with missing key" do
      expect(@config[:baz]).to be_nil
    end

    it "works with read-only data" do
      expect(@config[:consumer_key]).to eql("bar")
    end

    it "works with present key" do
      @config[:baz] = "hello"
      expect(@config[:baz]).to eql("hello")
    end
  end
end
