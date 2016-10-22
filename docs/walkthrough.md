---
layout: page
title: "Walkthrough"
category: tut
---

Make a Twitter account
----------------------

First thing you'll need to do is create an account for your bot on
Twitter.  That's the easy part.

Run the generator
-----------------

Chatterbot comes with a script named `chatterbot-register` which will
handle two tasks -- it will authorize your bot with Twitter and it
will generate a skeleton script, which you use to implement your
actual bot.

When you run `chatterbot-register` it will walk you through the
authorization process. If you prefer, you can do this manually. If
you'd like to learn more about it, you can read the
[Authorizing your Bot](chatterbot/setup.html) section.

Write your bot
--------------

Chatterbot is written in ruby, but it accepts some very simple
scripting commands which can handle almost everything you might need
to do on Twitter.  You can get some ideas of things you can do on the
[Examples](chatterbot/examples.html) page.

    require 'chatterbot/dsl'
    search("'surely you must be joking'") do |tweet|
      reply "@#{tweet_user(tweet)} I am serious, and don't call me Shirley!", tweet
    end

Or, you can create a bot object yourself, extend it if needed, and use it like so:

    bot = Chatterbot::Bot.new
    bot.search("'surely you must be joking'") do |tweet|
     bot.reply "@#{tweet_user(tweet)} I am serious, and don't call me Shirley!", tweet
    end

That's it!
