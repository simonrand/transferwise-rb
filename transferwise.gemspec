# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'transferwise/version'

Gem::Specification.new do |spec|
  spec.name          = "transferwise"
  spec.version       = Transferwise::VERSION
  spec.authors       = ["Harshvardhan Parihar", "Fernando Gorodscy"]
  spec.email         = ["harsh@milaap.org", "fegorodscy@gmail.com"]

  spec.summary       = "Ruby gem for Transferwise Apis"
  spec.description   = "Ruby gem for Transferwise Apis"
  spec.homepage      = "https://github.com/fegorodscy/transferwise-rb"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activesupport", ">= 3.0.0", "< 6.0"
  spec.add_runtime_dependency "oauth2", ">= 1.4.0", "< 2.0"
  spec.add_runtime_dependency "rest-client", ">= 1.4", "< 4.0"
  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 3.0"
end
