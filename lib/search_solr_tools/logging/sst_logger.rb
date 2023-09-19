# frozen_string_literal: true

require 'logging'
require 'search_solr_tools'

module SSTLogger
  def logger
    SSTLogger.logger
  end

  def set_log_environment(new_env)
    SSTLogger.set_log_environment(new_env)
  end

  class << self
    def logger
      @logger ||= new_logger
    end

    def set_log_environment(new_env)
      @env = new_env
      @logger = new_logger
    end

    def new_logger
      @env ||= :development
      logger = Logging.logger['search_solr_tools']

      append_stdout_logger(logger)
      append_file_logger(logger)

      logger
    end

    def append_stdout_logger(logger)
      return if log_stdout_level.nil?
      new_stdout = Logging.appenders.stdout
      new_stdout.level = log_stdout_level
      new_stdout.layout = Logging.layouts.pattern(pattern: "%-5l : %m\n")
      logger.add_appenders new_stdout
    end

    def append_file_logger(logger)
      return if log_file == 'none'
      new_file = Logging.appenders.file(
        log_file,
        layout: Logging.layouts.pattern(pattern: "[%d] %-5l : %m\n")
      )
      new_file.level = log_file_level
      logger.add_appenders new_file
    end

    def log_file
      env = SearchSolrTools::SolrEnvironments[@env]
      ENV.fetch('SEARCH_SOLR_LOG_FILE', nil) || env[:log_file]
    end

    def log_file_level
      env = SearchSolrTools::SolrEnvironments[@env]
      log_level(ENV.fetch('SEARCH_SOLR_LOG_LEVEL', nil) || env[:log_level])
    end

    def log_stdout_level
      env = SearchSolrTools::SolrEnvironments[@env]
      log_level(ENV.fetch('SEARCH_SOLR_STDOUT_LEVEL', nil) || env[:stdout_level])
    end

    def log_level(level)
      case (level || 'info').downcase
      when 'debug' then :debug
      when 'info' then :info
      when 'warn' then :warn
      when 'error' then :error
      when 'fatal' then :fatal
      else
        nil
      end
    end
  end
end
