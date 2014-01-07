# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'twitter_filter/version'

Gem::Specification.new do |spec|
  spec.name          = "twitter_filter"
  spec.version       = TwitterFilter::VERSION
  spec.authors       = ["Tom Livesey"]
  spec.email         = ["tjlivesey@gmail.com"]
  spec.description   = "Filters tweets by term and processes"
  spec.summary       = "Filters tweets by term and processes"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "twitter"
  spec.add_runtime_dependency "celluloid"
end
