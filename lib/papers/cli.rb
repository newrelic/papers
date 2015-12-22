require 'optparse'

module Papers

  class CLI

    def run
      if parse_options[:generate]
        begin
          generator = Papers::ManifestGenerator.new
          generator.generate!
        rescue Papers::FileExistsError => e
          warn "Error: 'papers_manifest.yml' already exists at '#{e.message}'. Aborting..."
        end
      end
    end

    private

    def parse_options
      options = {}
      opts = OptionParser.new do |opts|
        opts.banner = "Usage: papers [options]"

        opts.on("-g", "--generate", "Generate papers_manifest.yml") do |v|
          options[:generate] = v
        end

        opts.on_tail( '-h', '--help', 'Display this screen' ) do |v|
          p opts.to_s
          return {}
        end
      end.parse!

      p opts.to_s if options.empty?

      return options
    end
  end
end