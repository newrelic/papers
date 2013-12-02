require 'bundler'
require 'yaml'
require 'fileutils'

module Papers

  class ManifestGenerator

    def generate!
      manifest_path = File.join('config','papers_manifest.yml')

      if File.exist? manifest_path
        puts "Warning file already exists at #{manifest_path}. Aborting..."
        return
      else
        puts "Creating #{manifest_path}..."

        if FileUtils.mkdir_p(File.dirname(manifest_path))
          File.open(manifest_path, 'w') do |file|
            file.write(YAML.dump(build_manifest))
          end
          puts "Created manifest!"
        end
      end
    end

    private

    def build_manifest
      manifest = {}
      manifest["gems"]        = get_installed_gems
      manifest["javascripts"] = get_installed_javascripts
      return manifest
    end

    def get_installed_gems
      gems = {}
      Bundler.load.specs.each do |spec|
        gems["#{spec.name}-#{spec.version}"] = {
          'project_url' => spec.homepage,
          'license' => spec.license,
          'license_url' => ''
          # TODO: add support for multiple licenses? some gemspecs have dual licensing
        }
      end
      return gems
    end

    def get_installed_javascripts
      js = {}
      Javascript.introspected.each do |entry|
        js[entry] = {
          'license' => 'Unknown',
          'license_url' => '',
          'project_url' => ''
        }
      end
      js.empty? ? nil : js
    end

  end

end