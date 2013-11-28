
namespace :papers do

  desc "Generate a dependency list in config/paper_manifest.yml"
  task :generate_manifest do
    Papers::ManifestGenerator.generate!
  end

end