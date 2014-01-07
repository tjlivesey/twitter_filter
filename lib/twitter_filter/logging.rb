module TwitterFilter::Logging

  def self.setup(target = $stdout)
    @logger = Logger.new(target)
    @logger.level = Logger::INFO
    @logger
  end

  def self.logger
    @logger or setup
  end

  def self.logger=(logger)
    @logger = logger
  end

  def logger
    TwitterFilter::Logging.logger
  end

end