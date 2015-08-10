module Papers
  class DependencySpecification
    attr_accessor :name, :license, :license_url, :project_url

    def initialize(options)
      @name        = options[:name]
      @license     = options[:license]
      @license_url = options[:license_url]
      @project_url = options[:project_url]
    end

    def name_without_version
      return @name unless @name.include?('-')
      @name.rpartition('-')[0]
    end

    def acceptable_license?
      Papers.config.license_whitelist.include?(license) ||
      Papers.config.version_whitelisted_license == license
    end

    protected

      def self.all_from_manifest(manifest)
        (manifest[manifest_key] || []).map do |name, info|
          license_url = info['license_url']
          license = info['license']
          project_url = info['project_url']
          self.new(name: name, license: license, license_url: license_url, project_url: project_url)
        end.sort { |a, b| a.name.downcase <=> b.name.downcase }
      end

      def self.missing_from_manifest(manifest)
        introspected.to_set - all_from_manifest(manifest).map(&:name).to_set
      end

      def self.unknown_in_manifest(manifest)
        all_from_manifest(manifest).map(&:name).to_set - introspected.to_set
      end
  end
end
