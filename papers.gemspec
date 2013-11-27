# -*- encoding: utf-8 -*-

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'papers/version'

Gem::Specification.new do |s|
  s.name        = 'papers'
  s.version     = Papers::VERSION
  s.summary     = 'Validate the licenses of software dependencies you use'

  s.description = <<-DESCRIPTION
Validate that the licenses used by your Ruby project's dependencies (both gems
and javascript libraries) conform to a whitelist of software licenses. Don't get
caught flat-footed by the GPL.
  DESCRIPTION

  s.authors     = ['Ralph Bodenner', 'Jade Rubick', 'Lucas Charles']
  s.email       = 'support@newrelic.com'
  s.license     = 'MIT'
  s.homepage    = 'http://github.com/newrelic/papers'

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.require_paths = ["lib"]

  # dependencies
  s.add_dependency "rake"

  s.add_development_dependency 'rspec', '~> 2.14'
end
