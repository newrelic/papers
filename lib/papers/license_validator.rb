require 'yaml'

require 'papers/dependency_specification/gem'
require 'papers/dependency_specification/javascript'

module Papers
  class LicenseValidator
    attr_reader :errors

    def initialize
      @errors = []
    end

    def valid?
      @errors = []

      validate_gems if Papers.config.validate_gems?
      validate_js   if Papers.config.validate_javascript?

      @errors.empty?
    end

    def manifest
      @manifest ||= YAML.load_file(Papers.config.manifest_file)
    end

    def pretty_gem_list
      GemSpec.all_from_manifest(manifest).map(&:pretty_hash)
    end

    def pretty_js_list
      JsSpec.all_from_manifest(manifest).map(&:pretty_hash)
    end

    private

      def validate_spec_type(spec_type)
        spec_type.missing_from_manifest(manifest).each do |name|
          errors << "#{name} is included in the application, but not in the manifest"
        end

        spec_type.unknown_in_manifest(manifest).each do |name|
          errors << "#{name} is included in the manifest, but not in the application"
        end

        spec_type.all_from_manifest(manifest).each do |spec|
          unless spec.acceptable_license?
            errors << "#{spec.name} is licensed under #{spec.license}, which is not whitelisted"
          end
        end
      end

      def validate_gems
        validate_spec_type Gem
      end

      def validate_js
        validate_spec_type Javascript
      end
  end
end
