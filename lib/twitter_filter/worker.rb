class TwitterFilter::Worker
	include Celluloid
	attr_accessor :client

	def initialize
		Celluloid.logger = TwitterFilter.logger
		@client = Twitter
	end

	def process(klass, delivery)
		TwitterStream.logger.info "Processing object"
		klass.process(delivery)
		TwitterStream.logger.info "Processed successfully"
	end

end