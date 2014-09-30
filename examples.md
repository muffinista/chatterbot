---
layout: page
title: "Examples"
category: tut
---

Here's a couple examples of working bots.

@echoes_bot
-----------

This is a working bot. It responds to any mentions with the incoming
text:

<blockquote class="twitter-tweet" lang="en"><p><a href="https://twitter.com/muffinista">@muffinista</a> hello there!</p>&mdash; Echo Echo (@echoes_bot) <a href="https://twitter.com/echoes_bot/status/515166110950256640">September 25, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

Here's the code. This is right out of the git repo for chatterbot:

```
## This is a very simple working example of a bot you can build with
## chatterbot. It looks for mentions of '@echoes_bot' (the twitter
## handle the bot uses), and sends replies with the name switched to
## the handle of the sending user

#
# require the dsl lib to include all the methods you see below.
#
require 'rubygems'
require 'chatterbot/dsl'

puts "Loading echoes_bot.rb"

##
## If I wanted to exclude some terms from triggering this bot, I would list them here.
## For now, we'll block URLs to keep this from being a source of spam
##
exclude "http://"

blacklist "mean_user, private_user"

puts "checking for replies to me"
replies do |tweet|
  # replace the incoming username with #USER#, which will be replaced
  # with the handle of the user who tweeted us by the
  # replace_variables helper
  src = tweet.text.gsub(/@echoes_bot/, "#USER#")  

  # send it back!
  reply src, tweet
end
```


@SpaceJamCheck
--------------

This is another working bot. It checks the website for the movie Space
Jam to see if it is still online (it does this by using the spacejam
gem), and tweets the results of that check.


```
#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'chatterbot/dsl'
require 'spacejam'

#
# this is the script for the twitter bot SpaceJamCheck
# generated on 2013-11-04 16:24:46 -0500
#

consumer_key 'key'
consumer_secret 'secret'

secret 'secret'
token 'token'


check_url = "http://www2.warnerbros.com/spacejam/movie/jam.htm"
check_string = "<title>Space Jam</title>"

uptime_messages = [
                   "Hooray! Space Jam is still online!",
                   "It's #{Time.now.year} and the Space Jam website is still online",
                   "In case you were worried, Space Jam is still online",
                   "Looks like the Space Jam website is still there",
                   "Yes",
                   "Yep",
                   "Still Kickin",
                   "The Space Jam website is still online",
                   "Still Online"
                  ]

downtime_messages = [
                     "Hmm, looks like Space Jam isn't online. Hopefully it's a fluke ;("
                    ]


x = Spacejam::HTTPCheck.new(url:check_url, body:check_string)

# pick a random tweet according to the website status
result = if x.online?
  uptime_messages
else
  downtime_messages
end.sample

# add a timestamp. this helps to prevent duplicate tweet issues
result << " (#{Time.now.utc})"

# tweet it out!
tweet result
```


Streaming Bot
--------------


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
