# frozen_string_literal: true

require 'logging'

module SSTLogger
  def logger
    SSTLogger.logger
  end

  class << self
    def logger
      @logger ||= new_logger
    end

    def new_logger
      logger = Logging.logger['search_solr_tools']

      unless ENV.fetch('SOLR_HARVEST_STDOUT_LEVEL').nil?
        new_stdout = Logging.appenders.stdout
        new_stdout.level = log_level(ENV.fetch('SOLR_HARVEST_STDOUT_LEVEL'))
        new_stdout.layout = Logging.layouts.pattern(:pattern => "%-5l : %m\n")
        logger.add_appenders new_stdout
      end

      unless ENV.fetch('SOLR_HARVEST_LOG_FILE', nil) == 'none'
        new_file = Logging.appenders.rolling_file(
          log_file,
          age: 'daily',
          size: 10_000_000,
          layout: Logging.layouts.pattern(:pattern => "[%d] %-5l : %m\n")
        )
        new_file.level = log_level(ENV.fetch('SOLR_HARVEST_LOG_LEVEL', 'info'))
        logger.add_appenders new_file
      end

      logger
    end

    def log_level(level)
      case (level || 'info').downcase
      when 'debug' then :debug
      when 'info' then :info
      when 'warn' then :warn
      when 'error' then :error
      when 'fatal' then :fatal
      else
        :none
      end
    end

    def log_file
      ENV['SOLR_HARVEST_LOG_FILE'] ||= 'search-solr-tools.log'
    end
  end
end
