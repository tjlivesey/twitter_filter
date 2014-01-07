class TwitterFilter::Manager
	attr_accessor :worker_pool, :handlers, :client

	def initialize(options)
		@options = options
		@worker_pool = TwitterFilter::Worker.pool(options[:connections] or 1)
		@handlers = []
		@client = Twitter::Streaming::Client.new do |config|
  		config.consumer_key = options[:consumer_key]
  		config.consumer_secret = options[:consumer_secret]
  		config.access_token = options[:access_token]
  		config.access_token_secret = options[:access_token_secret]
		end
	end

	def register_handler(klass)
		handlers << klass
	end

	def start
		client.filter(track: @options[:filter]) do |object|
			worker_pool.handle
		end
	end

end