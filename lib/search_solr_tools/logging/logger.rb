require 'logging'

module Logger
  class << self
    def logger
      @logger ||= new_logger
    end

    def new_logger
      @logger = Logging.logger['search_solr_tools logger']
      @logger.level = log_level

      @logger.add_appender Logging.appenders.stdout unless ENV['SOLR_HARVEST_STDOUT'].downcase == 'silent'
      @logger.add_appender Logging.appenders.file(log_file)
    end

    def log_level
      case ENV['SOLR_HARVEST_LOG_LEVEL'].downcase
      when 'info' then :info
      when 'warn' then :warn
      when 'debug' then :debug
      when 'trace' then :trace
      when 'error' then :error
      else
        :info
      end
    end

    def log_file
      ENV['SOLR_HARVEST_LOG_FILE'] ||= 'tmp.log'
    end
  end
end