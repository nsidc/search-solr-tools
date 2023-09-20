# frozen_string_literal: true

require 'fileutils'
require 'logging'
require 'search_solr_tools'

module SSTLogger
  LOG_LEVELS = %w[debug info warn error fatal none].freeze

  def logger
    SSTLogger.logger
  end

  def log_environment(new_env)
    SSTLogger.log_environment(new_env)
  end

  class << self
    def logger
      @logger ||= new_logger
    end

    def log_environment(new_env)
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

      FileUtils.mkdir_p(File.dirname(log_file))
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
      log_level(ENV.fetch('SEARCH_SOLR_LOG_LEVEL', nil) || env[:log_file_level])
    end

    def log_stdout_level
      env = SearchSolrTools::SolrEnvironments[@env]
      log_level(ENV.fetch('SEARCH_SOLR_STDOUT_LEVEL', nil) || env[:log_stdout_level])
    end

    def log_level(level)
      LOG_LEVELS.include?(level) ? level : nil
    end
  end
end
