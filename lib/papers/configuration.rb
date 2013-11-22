module Papers
  class Configuration
    attr_accessor :license_whitelist

    attr_accessor :manifest_file

    attr_accessor :validate_gems

    attr_accessor :validate_javascript

    attr_accessor :javascript_paths

    def initialize
      @license_whitelist = [
        'MIT',
        'BSD',
        'Apache 2.0',
        'LGPLv2.1',
        'LGPLv3',
        'None'
      ]

      @manifest_file = File.join(Dir.pwd, 'config', 'dependency_manifest.yml')

      @validate_gems       = true
      @validate_javascript = false

      @javascript_paths = [
        File.join(Dir.pwd, 'app',    'assets', 'javascripts'),
        File.join(Dir.pwd, 'lib',    'assets', 'javascripts'),
        File.join(Dir.pwd, 'vendor', 'assets', 'javascripts')
      ]
    end

    def validate_gems?
      !!@validate_gems
    end

    def validate_javascript?
      !!@validate_javascript
    end
  end
end
