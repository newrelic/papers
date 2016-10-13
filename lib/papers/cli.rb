require 'optparse'

module Papers

  class CLI

    def run
      if options[:generate]
        begin
          Papers::ManifestGenerator.new.generate!
        rescue Papers::FileExistsError => e
          warn "Error: 'papers_manifest.yml' already exists at '#{e.message}'. Aborting..."
        end
      end

      if options[:update]
        Papers::ManifestUpdater.new.update!
      end
    end

    private

    def options
      @options ||= parse_options
    end

    def parse_options
      options = {}
      OptionParser.new do |opts|
        opts.banner = "Usage: papers [options]"

        opts.on("-g", "--generate", "Generate papers_manifest.yml") do |v|
          options[:generate] = v
        end

        opts.on("-u", "--update", "Update papers_manifest.yml for Rubygems") do |v|
          options[:update] = v
        end

        opts.on_tail( '-h', '--help', 'Display this screen' ) do |v|
          p opts
          exit
        end
        @avail_opts = opts
      end.parse!

      p @avail_opts if options.empty?

      return options
    end
  end
end
