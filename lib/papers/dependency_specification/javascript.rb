module Papers
  class Javascript < DependencySpecification
    def pretty_hash
      {
        name: @name,
        license: license,
        license_url: @license_url,
        project_url: @project_url
      }
    end

    def self.introspected
      dirs = Papers.config.javascript_paths
      whitelist_dirs = Papers.config.whitelist_javascript_paths

      # TODO: add logic for determining rails. Is Rails.root better than Dir.pwd for such a case?
      root_regexp = /^#{Regexp.escape Dir.pwd.to_s}\//
      files = dirs.map { |dir| Dir.glob("#{dir}/**/*.{js,coffee}") }.flatten.map do |name|
        name = name.sub(root_regexp, '')
        name unless whitelist_dirs.any? { |dir| name.start_with?(dir) }
      end
      files.compact
    end

    def self.manifest_key
      "javascripts"
    end
  end
end
