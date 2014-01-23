require 'json'

module Papers
  class BowerComponent < DependencySpecification
    def pretty_hash
      {
        name: name_without_version,
        license: license,
        license_url: @license_url,
        project_url: @project_url
      }
    end

    def self.introspected
      full_introspected_entries.map { |e| e['name'] }
    end

    def self.full_introspected_entries
      bower_json_entries.map do |entry|
        {
          'name' => "#{entry['name']}-#{entry['_release']}",
          'homepage' => entry['homepage']
        }
      end
    end

    def self.bower_json_entries
      json_files = Dir["#{Papers.config.bower_components_path}/*/.bower.json"]
      json_files.map do |path|
        JSON.parse File.read(path)
      end
    end

    def self.manifest_key
      "bower_components"
    end
  end
end
