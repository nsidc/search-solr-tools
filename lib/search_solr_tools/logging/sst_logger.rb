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
      @logger = Logging.logger['search_solr_tools logger']
      # @logger.level = log_level(ENV['SOLR_HARVEST_LOG_LEVEL'])

      unless ENV['SOLR_HARVEST_STDOUT_LEVEL'].nil?
        new_stdout = Logging.appenders.stdout
        new_stdout.level = log_level(ENV['SOLR_HARVEST_STDOUT_LEVEL'])
        @logger.add_appenders new_stdout
      end

      new_file = Logging.appenders.file(log_file)
      new_file.level = log_level(ENV['SOLR_HARVEST_LOG_LEVEL'])
      @logger.add_appenders new_file
    end

    def log_level(level)
      case (level || '').downcase
      when 'debug' then :debug
      when 'info' then :info
      when 'warn' then :warn
      when 'error' then :error
      when 'fatal' then :fatal
      else
        :info
      end
    end

    def log_file
      ENV['SOLR_HARVEST_LOG_FILE'] ||= 'search-solr-tools.log'
    end
  end
end