require 'optparse'
class TwitterFilter::CLI

	SUPPORTED_SIGNALS = %w(INT TERM)

	def run
		cli_options = parse_options
		working_dir = Dir.pwd

		if cli_options[:daemonize]
			unless cli_options[:pidfile]
				raise ArgumentError.new "You must specify a pidfile to daemonize"
			end
			daemonize(cli_options[:logfile])
		end

		TwitterFilter.logger.info "Starting filter..."
		load_rails(working_dir, cli_options[:environment])
		self_read, self_write = IO.pipe
		trap_signals(self_write)

		begin	

			manager = TwitterFilter::Manager.new
			File.open(cli_options[:pidfile], 'w') { |f| f.puts Process.pid } if cli_options[:pidfile]

			while readable_io = IO.select([self_read])
        signal = readable_io.first[0].gets.strip
        handle_signal(signal)
      end
		rescue Interrupt
			TwitterFilter.logger.info "Received interrupt, shutting down immediately..."
			TwitterFilter::Manager.stop
			exit(0)
		end
	end

	def trap_signals(self_write)
		SUPPORTED_SIGNALS.each do |sig|
      trap sig do
        self_write.puts(sig)
      end
    end
	end

  def daemonize(logfile_path)
  	if logfile_path
      [$stdout, $stderr].each do |io|
        File.open(logfile_path, 'ab') do |f|
          io.reopen(f)
        end
        io.sync = true
      end
      TwitterFilter::Logging.setup(logfile_path)
    end

    $stdin.reopen('/dev/null')
    Process.daemon
  end

	def handle_signal(signal)
		TwitterFilter.logger.info "Received #{signal} signal, shutting down gracefully..."
		TwitterFilter::Manager.stop
		exit(0)
	end

	def load_rails(directory, env=nil)
    ENV['RACK_ENV'] ||= env || ENV['RAILS_ENV'] || 'development'

    if File.directory?(".")
      require 'rails'
      require File.expand_path(directory + "/config/environment.rb")
      ::Rails.application.eager_load!
    end
  end

	def parse_options(args=ARGV)
    options = {}
		OptionParser.new do |opts|
		  opts.banner = "Usage: twitter_filter [options]"

		  [:consumer_key, :consumer_secret, :access_token, :access_token_secret].each do |opt|
			  opts.on("-#{opt.to_s}", "Twitter #{opt.to_s.split("_").join(" ")}") do |value|
			  	options[opt] = value
			  end
			end

		  opts.on("-c", "--concurrency COUNT", "Number of workers") do |count|
		  	abort "Minimum number of workers is 1" unless count.to_i > 0
		  	options[:concurrency] = count.to_i
		  end

		  opts.on("-f", "--filter", "Term to filter") do |opt|
		    options[:filter] = opt
		  end

		  opts.on("-d", "--daemonize", "Daemonize process") do |d|
		    options[:daemonize] = true
		  end

      opts.on '-L', '--logfile PATH', "path to writable logfile" do |path|
        options[:logfile] = File.expand_path(path)
      end

      opts.on '-P', '--pidfile PATH', "path to pidfile" do |path|
        options[:pidfile] = File.expand_path(path)
      end

      opts.on '-e', '--environment ENV', "Application environment" do |env|
        options[:environment] = env
      end

      opts.on('-h', '--help', 'Show this message and exit') do
        puts opts
        exit 0
      end

		end.parse!(args)
		options
  end

end
