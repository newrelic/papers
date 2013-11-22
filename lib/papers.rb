require 'papers/configuration'
require 'papers/license_validator'
require 'papers/version'

require 'papers/dependency_specification'
require 'papers/dependency_specification/gem'
require 'papers/dependency_specification/javascript'

module Papers
  def self.configure(&block)
    yield configuration
  end

  def configuration
    @config ||= configuration.new
  end
  alias config configuration
end