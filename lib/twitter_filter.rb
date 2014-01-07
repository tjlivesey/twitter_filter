require "twitter_filter/version"
require "celluloid"

module TwitterFilter
	autoload :Handler, "twitter_filter/handler"
	autoload :Manager, "twitter_filter/manager"
	autoload :Worker, "twitter_filter/worker"
	autoload :Logging, "twitter_filter/logging"

	def self.logger
		TwitterFilter::Logging.logger
	end
end
