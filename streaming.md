---
layout: page
title: "Streaming API"
category: doc
---

Chatterbot has basic support for Twitter's [Streaming API](https://dev.twitter.com/streaming/overview). If
you are an advanced developer, or want to create something very
involved, it might make more sense to use a different library.
However, if you do use Chatterbot, you can continue to use the DSL,
and you get access to a bunch of helpful routines.

Here's an example bot using the Streaming API:

```
#!/usr/bin/env ruby

## This is a very simple working example of a bot using the streaming
## API. It's basically a copy of echoes_bot.rb, just using streaming.

#
# require the dsl lib to include all the methods you see below.
#
require 'rubygems'
require 'chatterbot/dsl'

puts "Loading echoes_bot.rb using the streaming API"

exclude "http://", "https://"

blocklist "mean_user, private_user"

use_streaming
favorited do |user, tweet|
  reply "@#{user.screen_name} thanks for the fave!", tweet
end

followed do |user|
  tweet "@#{user.screen_name} just followed me!"
  follow user
end

replies do |tweet|
  favorite tweet

  puts "It's a tweet!"
  src = tweet.text.gsub(/@echoes_bot/, "#USER#")  
  reply src, tweet
end
```

By default, chatterbot will use the
[user endpoint](https://dev.twitter.com/streaming/userstreams), which
returns events for the bot -- mentions, follows, etc. If you specify a
`search` block in your bot, the filter endpoint will be used instead.


```
#
# run a search
#
use_streaming
search("Streaming API") do |tweet|
  puts tweet.text
end
```

