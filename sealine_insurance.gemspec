# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sealine_insurance/version'

Gem::Specification.new do |spec|
  spec.name          = 'sealine_insurance'
  spec.version       = SealineInsurance::VERSION
  spec.authors       = ['Roman Khrebtov']
  spec.email         = ['khrebtov.dev@gmail.com']

  spec.summary       = 'Ruby wrapper for Sealine API'
  spec.description   = 'Ruby wrapper for Sealine API'
  spec.homepage      = 'https://github.com/busfor/sealine_insurance'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '~> 0.9'
  spec.add_dependency 'money'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'webmock'
end
