# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'piglab/version'

Gem::Specification.new do |spec|
  spec.name          = "piglab"
  spec.version       = Piglab::VERSION
  spec.authors       = ["Ryan Breed"]
  spec.email         = ["opensource@breed.org"]

  spec.summary       = %q{ you know, for testing }
  spec.description   = %q{ you know, for testing }
  spec.homepage      = "https://github.com/ryanbreed/piglab"
  spec.license       = "MIT"

    spec.metadata['allowed_push_host'] = "http://nowhere.com'"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'snort-rule'
  spec.add_dependency 'packetfu'
  spec.add_dependency 'jls-grok', '0.10.10'

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'guard-bundler'
  spec.add_development_dependency 'guard-shell'
  spec.add_development_dependency 'guard-rake'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-doc'
end
