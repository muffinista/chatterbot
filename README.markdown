Chatterbot
===========

Chatterbot is a Ruby library for making bots on Twitter.  It is basic
enough that you can put it into use quickly, but can be used to make
pretty involved bots. It handles searches, replies and tweets, and has
a simple blacklist system to help keep you from spamming people who
don't want to hear from your bot.

[![Build Status](https://secure.travis-ci.org/muffinista/chatterbot.png?branch=master)](http://travis-ci.org/muffinista/chatterbot)


Features
--------
* Works via Twitter's OAuth system.
* Handles search queries and replies to your bot
* Use a simple DSL, or extend a Bot class if you need it
* Simple blacklistling system to limit your annoyance of users
* Optionally log tweets to the database for metrics and tracking purposes

Is Writing Bots a Good Use of My Time?
======================================

Quick answer: if you're planning on being spammish on Twitter, you
should probably find something else to do. If you're planning on
writing a bot that isn't too rude or annoying, or that expects a
certain amount of opt-in from users, then you're probably good. I've
written a blog post about bots on Twitter here:
http://muffinlabs.com/2012/06/04/the-current-state-of-bots-on-twitter/



Using Chatterbot
================

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

Chatterbot has a very simple DSL inspired by Sinatra and Twibot, an
earlier Twitter bot framework.  Here's an example, based on
[@dr_rumack](http://twitter.com/#!/Dr_Rumack), an actual bot running
on Twitter:

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

Chatterbot uses the the Twitter gem
(https://github.com/sferik/twitter) to handle the underlying API
calls. Any calls to the search/reply methods will return
Twitter::Status objects, which are basically extended hashes.

What Can I Do?
--------------

Here's a list of the important methods in the Chatterbot DSL:

**search** -- You can use this to perform a search on Twitter:

    search("'surely you must be joking'") do |tweet|
      reply "@#{tweet_user(tweet)} I am serious, and don't call me Shirley!", tweet
    end

**replies** -- Use this to check for replies and mentions:

    replies do |tweet|
      reply "Thanks for contacting me!", tweet
    end

**tweet** -- send a Tweet out for this bot:

    tweet "I AM A BOT!!!"

**reply** -- reply to another tweet:

    reply "THIS IS A REPLY!", original_tweet

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
your bot in a tweet, you will receive that tweet when calling the
reply method.

**exclude** -- similarly, you can specify a list of words/phrases
  which shouldn't trigger your bot. If you use the following:
  
    exclude "spam"
    
Any tweets or mentions with the word 'spam' in them will be ignored by
the bot. If you wanted to ignore any tweets with links in them (a wise
precaution if you want to avoid spreading spam), you could call:

    exclude "http://"

For more details, check out dsl.rb in the source code.


Authorization
-------------

If you only want to use Chatterbot to search for tweets, it will work
out of the box without any authorization.  However, if you want to
reply to tweets, or check for replies to your bot, you will have to
jump through a few authorization hoops with Twitter.

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
the instructions if you want to do it yourself:

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

1. In a YAML file with the same name as the bot, so if you have
   botname.rb or a Botname class, store your config in botname.yaml
2. In a global config file at `/etc/chatterbot.yml` -- values stored here
   will apply to any bots you run.
3. In another global config file specified in the environment variable
   `'chatterbot_config'`.
4. In a `global.yml` file in the same directory as your bot.  This
   gives you the ability to have a global configuration file, but keep
   it with your bots if desired.
5. In a database.  You can store your configuration in a DB, and then
   specify the connection string either in one of the global config
   files, or on the command-line by using the `--db="db_uri"`
   configuration option.  Any calls to the database are handled by the
   Sequel gem, and MySQL and Sqlite should work.  The DB URI should
   be in the form of `mysql://username:password@host/database` -- see
   http://sequel.rubyforge.org/rdoc/files/doc/opening_databases_rdoc.html
   for details.

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


Database logging
----------------

Chatterbot can log tweet activity to the database if desired.  This
can be handy for tracking what's going on with your bot.  See
`Chatterbot::Logging` for details on this.


Blacklists
----------

Not everyone wants to hear from your bot.  To keep annoyances to a
minimum, Chatterbot has a global blacklist option, as well as
bot-specific blacklists if desired.  The global blacklist is stored in
the database, and you can add entries to it by using the
`chatterbot-blacklist` script included with the gem.

You can also specify users to skip as part of the DSL:

    require 'chatterbot'
    blacklist "mean_user, private_user"

You should really respect the wishes of users who don't want to hear
from your bot, and add them to your blacklist whenever requested.

There's also an 'exclude' method which can be used to add
words/phrases you might want to ignore -- for example, if you wanted
to ignore tweets with links, you could do something like this:

    exclude "http://"

TODO
====

* document DSL methods
* document database setup
* web-based frontend for tracking bot activity
* opt-out system that adds people to blacklist if they reply to a bot
  in the right way

Contributing to Chatterbot
--------------------------

Since this code is based off of actual Twitter bots, it's mostly
working the way I want it to, and I might prefer to keep it that way.
But please, if there are bugs or things you would like to improve,
fork the project and hack away.  I'll pull anything back that makes
sense if requested.


Copyright/License
-----------------

Copyright (c) 2011 Colin Mitchell. Chatterbot is distributed under a
modified WTFPL licence -- it's the 'Do what the fuck you want to --
but don't be an asshole' public license.  Please see LICENSE.txt for
further details. Basically, do whatever you want with this code, but
don't be an asshole about it.  If you spam users inappropriately,
expect your karma to suffer.


http://muffinlabs.com


