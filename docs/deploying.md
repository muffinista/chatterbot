---
layout: page
title: "Running your Bot"
category: doc
---

There's a couple ways of running your bot:

Manually
--------

Run it on the command-line whenever you like. Whee!


Cron
----
Run it via cron.  Here's an example of running a bot every two minutes

    */2 * * * * . ~/.bash_profile; cd /path/to/bot/;  ./bot.rb

Looping
-------
Run it as a background process.  Just put the guts of your bot in a loop like this:

```rb
loop do
  search "twitter" do |tweet|
    # here you could do something with a tweet
    # if you want to retweet
    retweet(tweet[:id])
  end

  replies do |tweet|
    # do stuff
  end

  # explicitly update our config
  update_config

  sleep 60
end
```

**NOTE:** You need to call `update_config` to update the last tweet your script
has processed -- if you don't have this call, you will get duplicate
tweets.

Streaming
---------

Chatterbot has rough support for the Streaming API. If your bot can
use it, it's a great option, because you get your data immediately.
You can read more about setting up a bot to use [streaming](chatterbot/streaming.html).

