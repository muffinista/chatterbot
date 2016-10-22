---
layout: page
title: "Advanced Features"
category: doc
---

Direct Client Access
--------------------

If you want to do something not provided directly by Chatterbot, you
have access to an instance of Twitter::Client provided by the
**client** method. In theory, you can do something like this in your
bot to unfollow users who DM you:

    client.direct_messages_received(:since_id => since_id).each do |m|
        client.unfollow(m.user.name)
    end

Storing Config in the Database
------------------------------
Sometimes it is preferable to store the authorization credentials for
your bot in a database. 

Chatterbot can manage configurations that are stored in the database,
but to do this you will need to specify how to connect to the
database. You can do this by specifying the connection string
either in one of the global config files by setting 

```
:db_uri:mysql://username:password@host/database
```

Or you can specify the connection on the command-line by using the
--db="db_uri" configuration option. Any calls to the database are
handled by the Sequel gem, and MySQL and Sqlite should work. The DB
URI should be in the form of

    mysql://username:password@host/database 
    
see http://sequel.rubyforge.org/rdoc/files/doc/opening_databases_rdoc.html
for details.


Logging Tweets to the Database
------------------------------

Chatterbot can log tweet activity to a database if desired. This can
be handy for archival purposes, or for tracking what's going on with
your bot. 

If you've configured your bot for database access, you can store a
tweet to the database by calling the `log` method like this:

```
search "chatterbot" do |tweet|
    log tweet
end
```

See `Chatterbot::Logging` for details on this.


Streaming
---------

Chatterbot has basic support for Twitter's Streaming API. You can read
more about it [here](chatterbot/streaming.html)

