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

  before do
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with(path).and_return(original_content)

    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with(path).and_return(true)
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
end
