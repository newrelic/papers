$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'papers/version'

Gem::Specification.new do |s|
  s.name        = 'papers'
  s.version     = Papers::VERSION
  s.summary     = 'Validate the licences of software you use'

  s.description = <<-DESCRIPTION
Validate that the licenses used by your Ruby project's dependencies (both gems
and javascript libraries) conform to a whitelist of software licenses. Don't get
caught flat-footed by the GPL.
  DESCRIPTION

  s.authors     = ['Lucas Charles']
  s.email       = 'support@newrelic.com'
  s.license     = 'MIT'
  s.files       = Dir['lib/**/*.rb']
  s.homepage    = 'http://github.com/newrelic/papers'

  s.add_development_dependency 'rspec'
end
