---
layout: default
title: "Chatterbot - ruby for Twitter bots"
---

Chatterbot
===========

[Chatterbot](https://github.com/muffinista/chatterbot) is a Ruby library for making bots on Twitter.  It's
great for rapid development of bot ideas. It handles all of the basic
Twitter API features -- searches, replies, tweets, retweets, etc. and has
a simple blacklist/whitelist system to help minimize spam and unwanted
data.

A bot using chatterbot can be as simple as this:

```
exclude "http://"
blacklist "mean_user, private_user"

puts "checking my timeline"
home_timeline do |tweet|
    # i like to favorite things
    favorite tweet
end

puts "checking for replies to my tweets and mentions of me"
replies do |tweet|
  text = tweet.text
  puts "message received: #{text}"
  src = text.gsub(/@echoes_bot/, "#USER#")  

  # send it back!
  reply src, tweet
end
```

Or you can write a bot using more traditional ruby classes.

Chatterbot can actually generate a template bot file for you, and will
walk you through process of getting a bot authorized with Twitter.


Features
--------
* Handles search queries and replies to your bot
* Use a simple scripting language, or extend a Bot class if you need it
* Wraps the Twitter gem so you have access to the entire Twitter API
* Simple blacklistling system to limit your annoyance of users
* Avoid your bot making a fool of itself by ignoring tweets with
  certain bad words
* Basic Streaming API support
* Optionally log tweets to the database for metrics and tracking purposes


Chatterbot uses the the Twitter gem
(https://github.com/sferik/twitter) to handle the underlying API
calls. Any calls to the search/reply methods will return
`Twitter::Tweet` objects.


Copyright/License
-----------------

Copyright (c) 2014 Colin Mitchell. Chatterbot is distributed under the
WTFPL license.


http://muffinlabs.com

