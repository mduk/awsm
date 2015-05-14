# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'awsm/version'

Gem::Specification.new do |spec|
  spec.name          = "awsm"
  spec.version       = Awsm::VERSION
  spec.authors       = ["Daniel Kendell"]
  spec.email         = ["daniel@kendell.org"]
  spec.summary       = %q{Awsm AWS tool}
  spec.description   = %q{If you work with AWS, then Awsm wants to help make your life easier. Spin up/down ad-hoc instances as easily as `awsm spin up my_project`. Native ruby config file!}
  spec.homepage      = "http://github.com/mduk/awsm"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = [ 'awsm' ]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'thor', '~> 0.19'
  spec.add_runtime_dependency 'aws-sdk', '~> 2'
  spec.add_runtime_dependency 'terminal-table', '~> 1.4'
  spec.add_runtime_dependency 'mime', '~> 0.4'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency "pry", '~> 0.10'
end
