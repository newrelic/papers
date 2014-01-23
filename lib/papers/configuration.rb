module Papers
  class Configuration
    attr_accessor :license_whitelist

    attr_accessor :manifest_file

    attr_accessor :validate_gems
    attr_accessor :validate_javascript
    attr_accessor :validate_bower_components

    attr_accessor :javascript_paths
    attr_accessor :bower_components_path

    def initialize
      @license_whitelist = [
        'MIT',
        'BSD',
        'Apache 2.0',
        'Apache-2.0',
        'LGPLv2.1',
        'LGPLv3',
        'Ruby',
        'Manually Reviewed',
        'Unlicensed'
      ]

      @manifest_file = File.join(Dir.pwd, 'config', 'papers_manifest.yml')

      @validate_gems             = true
      @validate_javascript       = true
      @validate_bower_components = false

      @javascript_paths = [
        File.join(Dir.pwd, 'app',    'assets', 'javascripts'),
        File.join(Dir.pwd, 'lib',    'assets', 'javascripts'),
        File.join(Dir.pwd, 'vendor', 'assets', 'javascripts')
      ]

      @bower_components_path = File.join(Dir.pwd, 'vendor', 'assets', 'components')
    end

    def validate_gems?
      !!@validate_gems
    end

    def validate_javascript?
      !!@validate_javascript
    end

    def validate_bower_components?
      !!@validate_bower_components
    end
  end
end
