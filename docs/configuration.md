---
layout: page
title: "Configuration"
category: doc
---

You will need to store some information for your bot. This includes
the OAuth credentials, timestamps, etc.  Chatterbot offers a whole
bunch of different methods of storing the config for your bot:

1. Your credentials can be stored as variables in the script itself.
   If you generate a bot via `chatterbot-register`, the file will have
   these variables specified. However, if your bot source code is
   going to be public, you should NOT do this. Anyone who has your
   credentials can do nasty things with your Twitter account. Also, if
   your bot is using replies or searches, chatterbot will need to
   track some state information, and that data will be written to a
   YAML file.
2. In a YAML file with the same name as the bot, so if you have
   botname.rb or a Botname class, store your config in botname.yaml.
   `chatterbot-register` will also create this file. If you are using
   git or another source code control system, you should **NOT** store
   this file! It will be updated every time your bots run.
3. In a global config file at `/etc/chatterbot.yml` -- values stored here
   will apply to any bots you run.
4. In another global config file specified in the environment variable
   `'chatterbot_config'`.
5. In a `global.yml` file in the same directory as your bot.  This
   gives you the ability to have a global configuration file, but keep
   it with your bots if desired.
6. In a database.  You can read more about this on the [Advanced
   Features](chatterbot/advanced.html) page
