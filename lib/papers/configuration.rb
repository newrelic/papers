module Papers
  class Configuration
    attr_accessor :license_whitelist
    attr_accessor :version_whitelisted_license
    attr_accessor :package_whitelist

    attr_accessor :manifest_file

    attr_accessor :validate_gems
    attr_accessor :validate_javascript
    attr_accessor :validate_bower_components
    attr_accessor :validate_npm_packages
    attr_accessor :ignore_npm_dev_dependencies

    attr_accessor :javascript_paths
    attr_accessor :whitelist_javascript_paths
    attr_accessor :bower_components_path
    attr_accessor :npm_package_json_path

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
        'Unlicensed',
        'ISC'
      ]

      @package_whitelist = []

      @version_whitelisted_license = nil

      @manifest_file = File.join(Dir.pwd, 'config', 'papers_manifest.yml')

      @validate_gems             = true
      @validate_javascript       = true
      @validate_bower_components = false
      @validate_npm_packages = false
      @ignore_npm_dev_dependencies = false

      @javascript_paths = [
        File.join(Dir.pwd, 'app',    'assets', 'javascripts'),
        File.join(Dir.pwd, 'lib',    'assets', 'javascripts'),
        File.join(Dir.pwd, 'vendor', 'assets', 'javascripts')
      ]
      @whitelist_javascript_paths = []

      @bower_components_path = File.join(Dir.pwd, 'vendor', 'assets', 'components')

      @npm_package_json_path = File.join(Dir.pwd, 'package.json')
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

    def validate_npm_packages?
      !!@validate_npm_packages
    end

    def ignore_npm_dev_dependencies?
      !!@ignore_npm_dev_dependencies
    end

  end
end
