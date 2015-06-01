require 'logger'

module Chatterbot

  #
  # routines for outputting log messages, as well as logging tweets
  # to the database if desired.
  module Logging

    #
    # log a message
    def debug(s)
      puts s if verbose?
      logger.debug "#{botname} #{s}" unless ! logging?
    end

    #
    # something really bad happened, print it out and log it
    def critical(s)
      puts s
      debug s
    end
    
protected
    #
    # initialize a Logger object, writing to log_dest
    def logger
      # log to the dest specified in the config file, rollover after 10mb of data
      @_logger ||= Logger.new(log_dest, 0, 1024 * 1024)
    end

  end
end
