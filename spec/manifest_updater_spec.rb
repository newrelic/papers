require 'spec_helper'

describe Papers::ManifestUpdater do
  subject(:updater) { Papers::ManifestUpdater.new(path) }

  let(:path) { "/config/papers_manifest.yml" }

  let(:header) { <<EOS
# Dependency Manifest for the Papers gem
# Used to test your gems and javascript against license whitelist
#
# http://github.com/newrelic/papers
---
EOS
  }

  before do
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with(path).and_return(original_content)

    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with(path).and_return(true)
  end

  describe "Ruby" do
    let(:original_content) { <<EOS
#{header.chomp}
gems:
  rails-4.2.0:
    license: MIT
    license_url:
    project_url: https://github.com/rails/rails
  newrelic_rpm:
    license: New Relic
    license_url:
    project_url: https://github.com/newrelic/rpm
EOS
    }

    let(:shoes_license) { <<EOS
  shoes-4.0.0:
    license: MIT
    license_url:
    project_url: http://shoesrb.com
EOS
    }

    let(:foo_license) { <<EOS
      signed_payload-2.0.1:
        license: License Change! Was 'New Relic', is now ["Nonstandard"]
      license_url:
        project_url: https://source.datanerd.us/account-auth-and-access/signed_payload
EOS
    }

    it 'should avoid nesting license change messages' do
      gemspec = double(name: 'foo', version: '1.2.3', license: "some License Change! Was 'New Relic', is now [\"Nonstandard\"]", licenses: [], homepage: 'foo.com')

      result_gems = {}
      manifest_gem_key = 'foo'
      allow(result_gems).to receive(:delete).with(manifest_gem_key).and_return({
        'name' => 'foo',
        'version' => '1.2.3',
        'license' => "License Change! Was 'New Relic', is now [\"Nonstandard\"]",
        'homepage' => 'foo.com'
      })

      updater.update_gem(result_gems, gemspec, manifest_gem_key)
      expect(result_gems['foo']).to eq({
        'name' => 'foo',
        'version' => '1.2.3',
        'license' => "License Change! Was 'New Relic', is now [\"Nonstandard\"]",
        'homepage' => 'foo.com'
      })
    end

    it 'should work as normal for non nested changes' do
      gemspec = double(name: 'foo', version: '1.2.3', license: "asdf", licenses: [], homepage: 'foo.com')

      result_gems = {}
      manifest_gem_key = 'foo'
      allow(result_gems).to receive(:delete).with(manifest_gem_key).and_return({
        'name' => 'foo',
        'version' => '1.2.3',
        'license' => "ldkadfaldfjalkdsfj",
        'homepage' => 'foo.com'
      })

      updater.update_gem(result_gems, gemspec, manifest_gem_key)
      expect(result_gems['foo']).to eq({
        'name' => 'foo',
        'version' => '1.2.3',
        'license' => "License Change! Was 'ldkadfaldfjalkdsfj', is now [\"asdf\"]",
        'homepage' => 'foo.com'
      })
    end

    # We don't want to support it fully, but don't bomb out if we find an array
    it 'should handle array in manifest' do
      gemspec = double(name: 'foo', version: '1.2.3', license: "asdf", licenses: ["asdf", "new"], homepage: 'foo.com')

      result_gems = {}
      manifest_gem_key = 'foo'
      allow(result_gems).to receive(:delete).with(manifest_gem_key).and_return({
        'name' => 'foo',
        'version' => '1.2.3',
        'license' => ["asdf", "old"],
        'homepage' => 'foo.com'
      })

      updater.update_gem(result_gems, gemspec, manifest_gem_key)
      expect(result_gems['foo']).to eq({
        'name' => 'foo',
        'version' => '1.2.3',
        'license' => "License Change! Was '[\"asdf\", \"old\"]', is now [\"asdf\", \"new\"]",
        'homepage' => 'foo.com'
      })
    end

    it "avoids unnecessary updates" do
      allow(updater).to receive(:gemspecs).and_return([
        double(name: 'rails', version: '4.2.0', license: "MIT"),
        double(name: 'newrelic_rpm', version: '3.16.2.321', license: "New Relic")
      ])

      expect(updater.update).to eq(original_content)
    end

    it "updates version in place" do
      allow(updater).to receive(:gemspecs).and_return([
        double(name: 'rails', version: '4.2.7.1', license: "MIT"),
        double(name: 'newrelic_rpm', version: '3.16.2.321', license: "New Relic")
      ])

      expected = original_content.gsub(/rails-4.2.0/, "rails-4.2.7.1")
      expect(updater.update).to eq(expected)
    end

    it "adds new gems" do
      allow(updater).to receive(:gemspecs).and_return([
        double(name: 'rails', version: '4.2.0', license: "MIT"),
        double(name: 'newrelic_rpm', version: '3.16.2.321', license: "New Relic"),
        double(name: 'shoes', version: '4.0.0', license: "MIT", homepage: "http://shoesrb.com")
      ])

      expected = original_content + shoes_license
      expect(updater.update).to eq(expected)
    end

    it "deletes removed gems" do
      allow(updater).to receive(:gemspecs).and_return([
        double(name: 'shoes', version: '4.0.0', license: "MIT", homepage: "http://shoesrb.com")
      ])

      expected = "#{header}gems:\n#{shoes_license}"
      expect(updater.update).to eq(expected)
    end

    it "warns on change to license" do
      allow(updater).to receive(:gemspecs).and_return([
        double(name: 'rails', version: '5.0.0', license: "NOT-MIT", licenses: ["NOT-MIT"]),
        double(name: 'newrelic_rpm', version: '3.16.2.321', license: "New Relic", licenses: ["New Relic"]),
      ])

      expected = original_content.gsub(/rails-4.2.0/, "rails-5.0.0").
        sub(/MIT/, "License Change! Was 'MIT', is now [\"NOT-MIT\"]")
      expect(updater.update).to eq(expected)
    end

    it "doesn't touch licenses when missing license in gemspec" do
      allow(updater).to receive(:gemspecs).and_return([
        double(name: 'rails', version: '5.0.0', license: nil, licenses: []),
        double(name: 'newrelic_rpm', version: '3.16.2.321', license: "New Relic", licenses: ["New Relic"]),
      ])

      expected = original_content.gsub(/rails-4.2.0/, "rails-5.0.0")
      expect(updater.update).to eq(expected)
    end
  end

  describe "Javascript" do
    let(:original_content) { <<EOS
#{header.chomp}
javascripts:
  app/javascripts/instances/index.js:
    license: New Relic
    license_url: http://newrelic.com
    project_url: http://newrelic.com
  app/javascripts/instances/show.js:
    license: Unknown
    license_url:
    project_url:
bower_components:
  angular:
    license: MIT
    license_url:
    project_url:
  lodash:
    license: Unknown
    license_url:
    project_url:
npm_packages:
  react:
    license: MIT
    license_url:
    project_url:
  redux:
    license: Unknown
    license_url:
    project_url:
EOS
    }

    it "updates javascripts" do
      allow(Papers::Javascript).to receive(:introspected).and_return([
        "app/javascripts/instances/index.js",
        "app/javascripts/instances/delete.js"
      ])

      expected = original_content.sub(%r{/instances/show.js}, "/instances/delete.js")
      expect(updater.update).to eq(expected)
    end

    it "updates bower_components" do
      allow(Papers::BowerComponent).to receive(:full_introspected_entries).and_return([
        { "name" => "angular" },
        { "name" => "bower" }
      ])

      expected = original_content.sub(/lodash/, "bower")
      expect(updater.update).to eq(expected)
    end

    it "updates npm_packages" do
      allow(Papers::NpmPackage).to receive(:full_introspected_entries).and_return([
        { "name" => "react" },
        { "name" => "flow" }
      ])

      expected = original_content.sub(/redux/, "flow")
      expect(updater.update).to eq(expected)
    end
  end
end
