require 'json'

module Papers
  class NpmPackage < DependencySpecification
    def self.introspected
      full_introspected_entries.map {|e| "#{e['name']}-#{e['version']}"}
    end

    def self.full_introspected_entries
      packages = (package['dependencies'] || {}).merge((package['devDependencies'] || {}))
      packages.map do |name, version|
        version.sub!(/^\D+/, '')
        {
          'name' => name,
          'version' => version
        }
      end
    end

    def pretty_hash
      {
        name: name_without_version,
        license: license,
        license_url: @license_url,
        project_url: @project_url
      }
    end

    def self.asset_type_name
      'npm package'
    end

    def self.manifest_key
      "npm_packages"
    end

    private

    def self.package
      pkg = File.read(Papers.config.npm_package_json_path)
      JSON.parse(pkg)
    rescue Errno::ENOENT
      {}
    end
  end
end

