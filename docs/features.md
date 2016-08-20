---
layout: page
title: "Basic Features"
category: doc
---

Here's a list of some of the commonly-used methods in the Chatterbot DSL:

**search** -- You can use this to perform a search on Twitter:

    search("'surely you must be joking'") do |tweet|
      reply "#USER# I am serious, and don't call me Shirley!", tweet
    end
    
By default, Chatterbot keeps track of the last time you ran the bot,
and it will only search for new tweets.

**replies** -- Use this to check for replies and mentions:

    replies do |tweet|
      reply "#USER# Thanks for contacting me!", tweet
    end

Note that the string **#USER#** is automatically replaced with the
username of the person who sent the original tweet. Also, Chatterbot
will only return tweets that were sent since the last run of the bot.

**tweet** -- send a Tweet out for this bot:

    tweet "I AM A BOT!!!"

**reply** -- reply to another tweet:

    reply "THIS IS A REPLY TO #USER#!", original_tweet

**retweet** -- Chatterbot can retweet tweets as well:

```rb
  search "xyzzy" do |tweet|
    retweet(tweet[:id])
  end
```

**blacklist** -- you can use this to specify a list of users you don't
  want to interact with. If you put the following line at the top of
  your bot:
  
    blacklist "user1, user2, user3"
    
None of those users will trigger your bot if they come up in a
search. However, if a user replies to one of your tweets or mentions
your bot in a tweet, you will still receive that tweet when checking
for replies.

**exclude** -- similarly, you can specify a list of words/phrases
  which shouldn't trigger your bot. If you use the following:
  
    exclude "spam"
    
Any tweets or mentions with the word 'spam' in them will be ignored by
the bot. If you wanted to ignore any tweets with links in them (a wise
precaution if you want to avoid spreading spam), you could call:

    exclude "http://"

The library actually comes with a pre-defined list of 'bad words'
which you can exclude by default by calling:

    exclude bad_words
    
The word list is from Darius Kazemi's
[wordfilter](https://github.com/dariusk/wordfilter).


**whitelist**

**followers** -- get a list of your followers. This is an experimental
  feature but should work for most purposes.

**follow**

**profile_text**
**profile_website**


For more details, check out
[dsl.rb](https://github.com/muffinista/chatterbot/blob/master/lib/chatterbot/dsl.rb)
in the source code.
