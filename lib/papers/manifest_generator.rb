require 'bundler'
require 'yaml'
require 'fileutils'
require 'uri'

module Papers
  class FileExistsError < StandardError;
    attr_reader :manifest_path

    def initialize(path)
      @manifest_path = path
      super
    end
  end

  class ManifestGenerator < ManifestCommand
    def generate!(args = ARGV)
      raise Papers::FileExistsError.new(@manifest_path) if manifest_exists?

      begin
        if FileUtils.mkdir_p(File.dirname(@manifest_path))
          File.open(@manifest_path, 'w') do |file|
            file.write(build_header)
            file.write(YAML.dump(build_manifest))
          end
          puts "Created #{@manifest_path}!"
        end
      rescue RuntimeError => e
        warn "Failure! #{e}"
      end
    end

    private

    def build_manifest
      manifest = {
        "gems"             => get_installed_gems,
        "javascripts"      => get_installed_javascripts,
        "bower_components" => get_installed_bower_components,
        "npm_packages"     => get_installed_npm_packages
      }
      return manifest
    end

    def get_installed_gems
      gems = {}
      Bundler.load.specs.each do |spec|
        gems[gem_name_and_version(spec)] = gem_entry(spec)
      end
      return gems
    end

    def get_installed_javascripts
      js = {}
      Javascript.introspected.each do |entry|
        js[entry] = {
          'license'     => 'Unknown',
          'license_url' => nil,
          'project_url' => nil
        }
      end
      js.empty? ? nil : js
    end

    def get_installed_bower_components
      components = {}
      BowerComponent.full_introspected_entries.each do |entry|
        components[entry['name']] = {
          'license' => 'Unknown',
          'license_url' => nil,
          'project_url' => ensure_valid_url(entry['homepage'])
        }
      end
      components.empty? ? nil : components
    end

    def get_installed_npm_packages
      packages = {}
      NpmPackage.full_introspected_entries.each do |entry|
        packages[entry['name']] = {
          'license' => 'Unknown',
          'license_url' => nil,
          'project_url' => nil
        }
      end
      packages.empty? ? nil : packages
    end
  end

end
