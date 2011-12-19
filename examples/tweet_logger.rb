#!/usr/bin/env ruby

require 'chatterbot/dsl'

##
#
# Simple example of a bot that will log tweets to the
# database. Chatterbot will only log outgoing tweets by default, and
# coding incoming tweet processing seems problematic right now, but
# this is pretty straightforward
#

#
# Set some date defaults for Sequel
#
Sequel.datetime_class = DateTime
Sequel.default_timezone = :utc

#
# grab a copy of the db handle
#
db = bot.db

#
# create a table to hold search results
#
if ! db.tables.include?(:searches)

  #
  # if there's other data you want to track, you can add it here
  #
  db.create_table :searches do
    primary_key :id, :type=>Bignum

    String :text
    String :from_user
    String :from_user_id

    String :to_user
    String :to_user_id

    String :in_reply_to_status_id

    DateTime :created_at
  end
end

cols = db[:searches].columns

#
# run a search
#
search("foo", :lang => "en") do |tweet|

  #
  # reject anything from the incoming tweet that doesn't have a
  # matching column
  #
  data = tweet.delete_if { |k, v|
    ! cols.include?(k)
  }

  # update timestamp manually -- sequel isn't doing it right
  data[:created_at] ||= Sequel.string_to_datetime(data[:created_at])

  # store to the db!
  db[:searches].insert(data)
end
