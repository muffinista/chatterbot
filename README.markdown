Chatterbot
===========

Hey! This is Chatterbot 2.0. There have been some breaking changes
from older versions of the library, and it doesn't support MySQL
anymore. If you are looking for the old version, 
you can try the [1.0 branch](https://github.com/muffinista/chatterbot/tree/1.0.2)

Chatterbot is a Ruby library for making bots on Twitter.  It's
great for rapid development of bot ideas. It handles all of the basic
Twitter API features -- searches, replies, tweets, retweets, etc. and has
a simple blacklist/whitelist system to help minimize spam and unwanted
data.

[![Build Status](https://secure.travis-ci.org/muffinista/chatterbot.png?branch=master)](http://travis-ci.org/muffinista/chatterbot)

Features
--------
* Handles search queries and replies to your bot
* Use a simple scripting language, or extend a Bot class if you need it
* Wraps the Twitter gem so you have access to the entire Twitter API
* Simple blocklist system to limit your annoyance of users
* Avoid your bot making a fool of itself by ignoring tweets with
  certain bad words
* Basic Streaming API support


Using Chatterbot
================

Chatterbot has a [documentation
website](http://muffinista.github.io/chatterbot/). It's a
work-in-progress. You can also read the [gem
documentation](http://www.rubydoc.info/gems/chatterbot/).



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

Write your bot
--------------

A bot using chatterbot can be as simple as this:

```
exclude "http://"
blocklist "mean_user, private_user"

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

Or you can write a bot using more traditional ruby classes, extend it if needed, and use it like so:
```
  class MyBot < Chatterbot::Bot
     def do_stuff
       home_timeline do |tweet|
         puts "I like to favorite things"
         favorite tweet
       end
    end
  end
```

Chatterbot can actually generate a template bot file for you, and will
walk you through process of getting a bot authorized with Twitter.

That's it!

Chatterbot uses the the Twitter gem
(https://github.com/sferik/twitter) to handle the underlying API
calls. Any calls to the search/reply methods will return
Twitter::Status objects, which are basically extended hashes. If you
find yourself pushing the limits of Chatterbot, it's very possible
that you should just be using the Twitter gem directly.

Streaming
---------

Chatterbot has some basic support for the Streaming API. If you want
to do something complicated, you should probably consider using the
[Twitter gem](https://github.com/sferik/twitter#streaming) directly. 

Basic usage is very straightforward:

    use_streaming true
    home_timeline do |tweet|
      puts "someone i follow tweeted! #{tweet.text}"
    end


You can also run a search:

    use_streaming true
    search("pizza") do |tweet|
      puts "someone is talking about pizza! #{tweet.text}"
    end



What Can I Do?
--------------

Here's a list of the important methods in the Chatterbot DSL:

**search** -- You can use this to perform a search on Twitter:

    search("pizza") do |tweet|
      tweet "I just read another tweet about pizza"
    end

**replies** -- Use this to check for replies and mentions:

    replies do |tweet|
      reply "#USER# Thanks for contacting me!", tweet
    end

Note that the string #USER# will be replaced with the username of the
person who sent the original tweet.

**home_timeline** -- This call will return tweets from the bot's home
  timeline -- this will include tweets from accounts the bot follows,
  as well as the bot's own tweets:
  
    home_timeline do |tweet|
      puts tweet.text # this is the actual tweeted text
      favorite tweet # i like to fave tweets
    end

**direct_messages** -- This will return any DMs for the bot:

    direct_messages do |dm|
      puts dm.text

      # send a DM back to the user
      direct_message "Hey, I got your message at #{Time.now.to_s}", dm.sender
    end


**tweet** -- send a Tweet out for this bot:

    tweet "I AM A BOT!!!"

**reply** -- reply to another tweet:

    reply "THIS IS A REPLY TO #USER#!", original_tweet

**retweet** -- Chatterbot can retweet tweets as well:

```rb
  search "xyzzy" do |tweet|
    retweet(tweet.id)
  end
```

**direct_message** -- send a DM to a user:

    direct_message "I am a bot sending you a direct message", user

(NOTE: you'll need to make sure your bot has permission to send DMs)

**blocklist** -- you can use this to specify a list of users you don't
  want to interact with. If you put the following line at the top of
  your bot:
  
    blocklist "user1, user2, user3"
    
None of those users will trigger your bot if they come up in a
search. However, if a user replies to one of your tweets or mentions
your bot in a tweet, you will receive that tweet when calling the
reply method.

**exclude** -- similarly, you can specify a list of words/phrases
  which shouldn't trigger your bot. If you use the following:
  
    exclude "spam"
    
Any tweets or mentions with the word 'spam' in them will be ignored by
the bot. If you wanted to ignore any tweets with links in them (a wise
precaution if you want to avoid spreading spam), you could call:

    exclude "http://"

**followers** -- get a list of your followers. This is an experimental
  feature but should work for most purposes.

For more details, check out
[dsl.rb](https://github.com/muffinista/chatterbot/blob/master/lib/chatterbot/dsl.rb)
in the source code.



Direct Client Access
--------------------

If you want to do something not provided by the DSL, you have access
to an instance of Twitter::Client provided by the **client** method.
In theory, you can do something like this in your bot to unfollow
users who DM you:

    client.direct_messages_received(:since_id => since_id).each do |m|
        client.unfollow(m.user.name)
    end


Authorization
-------------

Before you setup a bot for the first time, you will need to register an
application with Twitter.  Twitter requires all API communication to be via an
app which is registered on Twitter. I would set one up and make it
part of Chatterbot, but unfortunately Twitter doesn't allow developers
to publicly post the OAuth consumer key/secret that you would need to
use.  If you're planning to run more than one bot, you only need to do
this step once -- you can use the same app setup for other bots too.

The helper script `chatterbot-register` will walk you through most of
this without too much hand-wringing. And, if you write a bot without
`chatterbot-register`, you'll still be sent through the authorization
process the first time you run your script.  But if you prefer, here's
sthe instructions if you want to do it yourself:

1. [Setup your own app](https://twitter.com/apps/new) on Twitter.

2. Put in whatever name, description, and website you want.

3. Take the consumer key/consumer secret values, and either run your bot, and enter them
in when prompted, or store them in a config file for your bot. (See
below for details on this).  It should look like this:

 		 ---
         :consumer_secret: CONSUMER SECRET GOES HERE
         :consumer_key: CONSUMER KEY GOES HERE


When you do this via the helper script, chatterbot will point you at
the URL in Step #1, then ask you to paste the same values as in Step #4.

Once this is done, you will need to setup authorization for the actual
bot with Twitter. At the first run, you'll get a message asking you to go
to a Twitter URL, where you can authorize the bot to post messages for
your account or not.  If you accept, you'll get a PIN number back.
You need to copy this and paste it back into the prompt for the
bot. Hit return, and you should be all set.

This is obviously a bunch of effort, but once you're done, you're
ready to go!

Configuration
-------------

Chatterbot offers a couple different methods of storing the config for
your bot:

1. Your credentials can be stored as variables in the script itself.
   `chatterbot-register` will do this for you. If your bot is using
   replies or searches, that data will be written to a YAML file.
   **NOTE** this is a bad practice for scripts that are stored in a
   source control system such as git, or are publicly available on a
   site like github.
2. In a YAML file with the same name as the bot, so if you have
   botname.rb or a Botname class, store your config in botname.yaml
3. In a global config file at `/etc/chatterbot.yml` -- values stored here
   will apply to any bots you run.
4. In another global config file specified in the environment variable
   `'chatterbot_config'`.
5. In a `global.yml` file in the same directory as your bot.  This
   gives you the ability to have a global configuration file, but keep
   it with your bots if desired.

Running Your Bot
----------------

There's a couple ways of running your bot:

Run it on the command-line whenever you like. Whee!

Run it via cron.  Here's an example of running a bot every two minutes

    */2 * * * * . ~/.bash_profile; cd /path/to/bot/;  ./bot.rb




Run it as a background process.  Just put the guts of your bot in a loop like this:

```rb
loop do
  search "twitter" do |tweet|
    # here you could do something with a tweet
    # if you want to retweet
    retweet(tweet.id)
  end

  replies do |tweet|
    # do stuff
  end

  sleep 60
end
```


Blocklists
----------

Not everyone wants to hear from your bot.  To keep annoyances to a
minimum, Chatterbot has a simple blocklist tool. Using it is as simple as:

    blocklist "mean_user, private_user"

You should really respect the wishes of users who don't want to hear
from your bot, and add them to your blocklist whenever requested.

There's also an 'exclude' method which can be used to add
words/phrases you might want to ignore -- for example, if you wanted
to ignore tweets with links, you could do something like this:

    exclude "http://"

Contributing to Chatterbot
--------------------------

Pull requests for bug fixes and new features are eagerly accepted.
Since this code is based off of actual Twitter bots, please try and
maintain compatability with the existing codebase. If you are
comfortable writing a spec for any changed code, please do so. If not,
I can work with you on that.

Copyright/License
-----------------

Copyright (c) 2016 Colin Mitchell. Chatterbot is distributed under the
MIT licence -- Please see LICENSE.txt for further details.

http://muffinlabs.com


