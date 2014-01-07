class TwitterFilter::Handler
	def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
  	def handle(filter_term)
  		Manager.register_handler(self)
  	end
  end
end