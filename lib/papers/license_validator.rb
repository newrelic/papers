require 'yaml'

require 'papers/dependency_specification'
require 'papers/dependency_specification/gem'
require 'papers/dependency_specification/javascript'
require 'papers/dependency_specification/bower_component'
require 'papers/dependency_specification/npm_package'

module Papers
  class LicenseValidator
    attr_reader :errors

    def initialize
      @errors = []
    end

    def valid?
      @errors = []

      validate_spec_type(Gem)            if Papers.config.validate_gems?
      validate_spec_type(Javascript)     if Papers.config.validate_javascript?
      validate_spec_type(BowerComponent) if Papers.config.validate_bower_components?
      validate_spec_type(NpmPackage)     if Papers.config.validate_npm_packages?

      @errors.empty?
    end

    def manifest
      @manifest ||= YAML.load_file(Papers.config.manifest_file)
    end

    def pretty_gem_list
      Gem.all_from_manifest(manifest).map(&:pretty_hash)
    end

    def pretty_js_list
      Javascript.all_from_manifest(manifest).map(&:pretty_hash)
    end

    def pretty_bower_component_list
      BowerComponent.all_from_manifest(manifest).map(&:pretty_hash)
    end

    def pretty_npm_package_list
      NpmPackage.all_from_manifest(manifest).map(&:pretty_hash)
    end

    private

      def validate_spec_type(spec_type)
        asset_type_name = spec_type.asset_type_name
        spec_type.missing_from_manifest(manifest).each do |name|
          errors << "#{asset_type_name} #{name} is included in the application, but not in the manifest"
        end

        spec_type.unknown_in_manifest(manifest).each do |name|
          errors << "#{asset_type_name} #{name} is included in the manifest, but not in the application"
        end

        spec_type.all_from_manifest(manifest).each do |spec|
          unless spec.acceptable_license?
            errors << "#{asset_type_name} #{spec.name} is licensed under #{spec.license}, which is not whitelisted"
          end
        end
      end
  end
end
