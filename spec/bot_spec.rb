require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Bot" do
  after(:each) do
    b = Chatterbot::Bot.new(:reset_since_id => false)
  end

  describe "reset_bot?" do
    it "should call reset_since_id and update_config" do
      expect_any_instance_of(Chatterbot::Bot).to receive(:reset_since_id)
      expect_any_instance_of(Chatterbot::Bot).to receive(:update_config)
      allow_any_instance_of(Chatterbot::Bot).to receive(:exit)
      b = Chatterbot::Bot.new(:reset_since_id => true)
    end

  end
end
