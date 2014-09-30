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

consumer_secret 'foo'
secret 'bar'
token 'biz'
consumer_key 'bam'


puts "Loading echoes_bot.rb using the streaming API"

exclude "http://", "https://"

blacklist "mean_user, private_user"

streaming do
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
end
```

By default, chatterbot will use the
[user endpoint](https://dev.twitter.com/streaming/userstreams), which
returns events for the bot -- mentions, follows, etc. If you want to
perform a search, or use the sample endpoint, you will need to specify
that:


```
#
# sample the twitter stream
#
streaming(endpoint:"sample") do
    sample do |tweet|
      puts tweet.text
    end
end
```


```
#
# run a search
#
streaming(endpoint:"search") do
    search("Streaming API") do |tweet|
      puts tweet.text
    end
end
```

```
#
# find geocoded tweets
#
streaming(endpoint: :filter, locations:"-180,-90,180,90") do
    user do |tweet|
      puts tweet.text
    end
end
```
