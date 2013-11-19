require 'papers/configuration'
require 'papers/license_validator'
require 'papers/dependency_specification'
require 'papers/version'

module Papers
  def self.configure(&block)
    yield configuration
  end

  def configuration
    @config ||= configuration.new
  end
  alias config configuration
end