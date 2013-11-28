require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Chatterbot::Reply" do
  it "calls require_login" do
    bot = test_bot
    bot.should_receive(:require_login).and_return(false)
    bot.replies
  end

  it "updates since_id_reply when complete" do
    bot = test_bot
    bot.should_receive(:require_login).and_return(true)
    results = fake_replies(1, 1000)

    bot.stub!(:client).and_return(results)
    
    bot.replies do
    end

    bot.config[:tmp_since_id_reply].should == 1000
  end

  it "iterates results" do
    bot = test_bot
    bot.should_receive(:require_login).and_return(true)
    bot.stub!(:client).and_return(fake_replies(3))
    
    bot.should_receive(:update_since_id_reply).exactly(3).times

    indexes = []
    bot.replies do |x|
      indexes << x[:id]
    end

    indexes.should == [1,2,3]
  end

  it "checks blacklist" do
    bot = test_bot
    bot.should_receive(:require_login).and_return(true)
    bot.stub!(:client).and_return(fake_replies(3))
    
    bot.stub!(:on_blacklist?).and_return(true, false, false)


    indexes = []
    bot.replies do |x|
      indexes << x[:id]
    end

    indexes.should == [2,3]
  end


  it "passes along since_id_reply" do
    bot = test_bot
    bot.should_receive(:require_login).and_return(true)
    bot.stub!(:client).and_return(fake_replies(100, 3))    
    bot.stub!(:since_id_reply).and_return(123)
    
    bot.client.should_receive(:mentions).with({:since_id => 123, :count => 200})

    bot.replies
  end
  

  it "doesn't pass along invalid since_id_reply" do
    bot = test_bot
    bot.should_receive(:require_login).and_return(true)
    bot.stub!(:client).and_return(fake_replies(100, 3))    
    bot.stub!(:since_id_reply).and_return(0)
    
    bot.client.should_receive(:mentions).with({:count => 200})

    bot.replies
  end

  it "pass along since_id if since_id_reply is nil or zero" do
    bot = test_bot
    bot.should_receive(:require_login).and_return(true)
    bot.stub!(:client).and_return(fake_replies(100, 3))
    bot.stub!(:since_id).and_return(12345)

    bot.client.should_receive(:mentions).with({:count => 200, :since_id => 12345})

    bot.replies

  end
end
