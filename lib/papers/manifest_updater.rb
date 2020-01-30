require 'bundler'
require 'yaml'
require 'fileutils'
require 'uri'

module Papers
  class FileMissingError < StandardError
    def initialize(file)
      super("Manifest file #{file} missing, can't update.")
    end
  end

  class ManifestUpdater < ManifestCommand
    def update!
      updated_content = update
      File.open(@manifest_path, 'w') do |file|
        file.write(updated_content)
      end

      puts "Updated #{@manifest_path}! Run your tests and check your diffs!"
    end

    def update
      raise Papers::FileMissingError.new(@manifest_path) unless manifest_exists?

      original_content = File.read(@manifest_path)
      result = YAML.load(original_content)

      update_gems(result)
      update_javascript(result, "javascripts", get_installed_javascripts)
      update_javascript(result, "bower_components", get_installed_bower_components)
      update_javascript(result, "npm_packages", get_installed_npm_packages)

      manifest_content = build_header + YAML.dump(result)

      # strip trailing whitespace, ensure file ends with a newline
      manifest_content.gsub(/\s*$/, '') + "\n"
    end

    def update_gems(result)
      result_gems = result["gems"]
      return unless result_gems

      manifest_names = manifest_names(result_gems)
      gemspecs.each do |gemspec|
        if manifest_gem_key = manifest_names[gemspec.name]
          update_gem(result_gems, gemspec, manifest_gem_key)
        else
          new_gem(result_gems, gemspec)
        end
      end

      delete_gems(result_gems, manifest_names)
    end

    def update_javascript(result, key, installed)
      existing = result[key]
      return unless existing && installed

      removed = existing.keys - installed.keys

      # Merge over new results from existing to keep edits
      installed.merge!(existing)

      # Remove things that aren't installed anymore
      removed.each do |remove|
        installed.delete(remove)
      end

      result[key] = installed
    end

    def update_gem(result_gems, gemspec, manifest_gem_key)
      manifest_gem = result_gems.delete(manifest_gem_key)
      if gemspec.license && gemspec.license != manifest_gem["license"]
        new_licenses = gemspec.licenses || []
        new_licenses << gemspec.license
        new_licenses.uniq!

        manifest_gem["license"] = "License Change! Was '#{manifest_gem["license"]}', is now #{new_licenses}"
      end

      name = gem_name_and_version(gemspec)
      name = gemspec.name if gemspec.name == manifest_gem_key
      result_gems[name] = manifest_gem
    end

    def new_gem(result_gems, gemspec)
      result_gems[gem_name_and_version(gemspec)] = gem_entry(gemspec)
    end

    def delete_gems(result_gems, manifest_names)
      # Find removed gems
      manifest_names.each do |(gem_name, gem_key)|
        if gemspecs.none? { |gem| gem.name == gem_name }
          result_gems.delete(gem_key)
        end
      end
    end

    def name_from_key(key)
      key.include?("-") ? key.rpartition("-").first : key
    end

    def manifest_names(result_gems)
      result_gems.reduce({}) do |hash, (key, _)|
        hash[name_from_key(key)] = key
        hash
      end
    end

    def gemspecs
      @gemspecs ||= Bundler.load.specs.dup
    end
  end
end
