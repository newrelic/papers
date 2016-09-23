module Papers
  class ManifestCommand
    def initialize(manifest_path = nil)
      @manifest_path = manifest_path || File.join('config','papers_manifest.yml')
    end

    def manifest_exists?
      !!File.exist?(@manifest_path)
    end

    def build_header
      [
        "# Dependency Manifest for the Papers gem",
        "# Used to test your gems and javascript against license whitelist",
        "#",
        "# http://github.com/newrelic/papers\n"
      ].join("\n")
    end

    def gem_name_and_version(spec)
      if spec.name == 'bundler'
        name_and_version = spec.name
      else
        name_and_version = "#{spec.name}-#{spec.version}"
      end
    end

    def gem_entry(spec)
      gem_license     = blank?(spec.license) ? 'Unknown' : spec.license
      gem_project_url = blank?(spec.homepage) ? nil : spec.homepage

      {
        'license'     => gem_license,
        'license_url' => nil,
        'project_url' => ensure_valid_url(gem_project_url)
        # TODO: add support for multiple licenses? some gemspecs have dual licensing
      }
    end

    def blank?(str)
      str.respond_to?(:empty?) ? str.empty? : !str
    end

    def ensure_valid_url(url_string)
      match_url = URI::regexp.match(url_string)
      if match_url.nil?
        nil
      else
        match_url[0]
      end
    end
  end
end
