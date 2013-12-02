require 'papers/configuration'
require 'papers/license_validator'
require 'papers/manifest_generator'
require 'papers/version'

require 'papers/dependency_specification'
require 'papers/dependency_specification/gem'
require 'papers/dependency_specification/javascript'

module Papers
  def self.configure(&block)
    yield configuration
  end

  def self.configuration
    @config ||= Configuration.new
  end

  # alias
  def self.config
    configuration
  end

end