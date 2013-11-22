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
      dirs = []
      dirs << File.join(Rails.root, "app", "assets", "javascripts")

      root_regexp = /^#{Regexp.escape Rails.root.to_s}\//
      dirs.map { |dir| Dir["#{dir}/**/*.js"] }.flatten.map { |name| name.sub(root_regexp, '') }
    end

    def self.manifest_key
      "javascripts"
    end
  end
end
