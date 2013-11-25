require 'bundler/setup'
require 'rspec'
require_relative '../lib/papers'

describe 'Papers' do

  let(:validator) { Papers::LicenseValidator.new }

  it 'validates a manifest with empty values and set of dependencies' do
    Papers::LicenseValidator.any_instance.stub(:manifest).and_return({
      "javascripts" => {},
      "gems" => {}
    })
    Papers::Gem.stub(:introspected).and_return([])

    expect(validator.valid?).to be_true
  end

  it 'detects mismatched gems' do
    Papers::LicenseValidator.any_instance.stub(:manifest).and_return({
        "javascripts" => {},
        "gems" => {
          "foo-1.2" => {
            'license' => "MIT",
            'license_url' => nil,
            'project_url' => nil
          },
          "baz-1.3" => {
            'license' => "BSD",
            'license_url' => nil,
            'project_url' => nil
          }
        }
      })
    Papers::Gem.stub(:introspected).and_return(["bar-1.2", "baz-1.3"])

    expect(validator.valid?).to be_false

    expect(validator.errors).to eq([
      "bar-1.2 is included in the application, but not in the manifest",
      "foo-1.2 is included in the manifest, but not in the application"
    ])

    validator.valid?
  end

  it 'detects mismatched gem versions' do
    Papers::Configuration.any_instance.stub(:validate_javascript?).and_return(true)

    expect(validator).to receive(:validate_js).at_least(:once)

    Papers::LicenseValidator.any_instance.stub(:manifest).and_return({
      "javascripts" => {},
      "gems" => {
        "foo-1.2" => {
          'license' => "MIT",
          'license_url' => nil,
          'project_url' => nil
        },
        "baz-1.3" => {
          'license' => "BSD",
          'license_url' => nil,
          'project_url' => nil
        }
      }
    })
    Papers::Gem.stub(:introspected).and_return(["foo-1.2", "baz-1.2"])

    expect(validator.valid?).to be_false

    expect(validator.errors).to eq([
      "baz-1.2 is included in the application, but not in the manifest",
      "baz-1.3 is included in the manifest, but not in the application"
    ])
    validator.valid?
  end

  it 'is OK with matching gem sets' do
    Papers::LicenseValidator.any_instance.stub(:manifest).and_return({
      "javascripts" => {},
      "gems" => {
        "foo-1.2" => {
          'license' => "MIT",
          'license_url' => nil,
          'project_url' => nil
        },
        "baz-1.3" => {
          'license' => "BSD",
          'license_url' => nil,
          'project_url' => nil
        }
      },
    })
    Papers::Gem.stub(:introspected).and_return(["foo-1.2", "baz-1.3"])

    expect(validator.valid?).to be_true
  end

  it 'is OK with matching gem sets but complain about a license issue' do
    Papers::LicenseValidator.any_instance.stub(:manifest).and_return({
      "javascripts" => {},
      "gems" => {
        "foo-1.2" => {
          'license' => "MIT",
          'license_url' => nil,
          'project_url' => nil
        },
        "baz-1.3" => {
          'license' => "GPL",
          'license_url' => nil,
          'project_url' => nil
        }
      },
    })
    Papers::Gem.stub(:introspected).and_return(["foo-1.2", "baz-1.3"])

    expect(validator.valid?).to be_false

    expect(validator.errors).to eq([
      "baz-1.3 is licensed under GPL, which is not whitelisted"
    ])

    validator.valid?
  end

  # TEMP: this test doesn't do what its saying
  xit 'allows a license_url in the manifest definition' do
    #     Papers::LicenseValidator.any_instance.stub(:manifest).and_return({
    #   "javascripts" => {},
    #   "gems" => {
    #     "foo-1.2" => {
    #       'license' => "MIT",
    #       'license_url' => nil,
    #       'project_url' => nil
    #     },
    #     "baz-1.3" => {
    #       'license' => "BSD",
    #       'license_url' => nil,
    #       'project_url' => nil
    #     }
    #   },
    # })
    # Papers::Gem.stub(:introspected).and_return(["bar-1.2", "baz-1.3"])

    # expect(validator.valid?).to be_false
    # expect(validator.errors).to eq([
    #   "bar-1.2 is included in the application, but not in the manifest",
    #   "foo-1.2 is included in the manifest, but not in the application"
    # ])
  end

  it 'displays gem licenses in a pretty format without versions' do
    Papers::LicenseValidator.any_instance.stub(:manifest).and_return({
      "javascripts" => {},
      "gems" => {
        "foo-1.2" => {
          'license' => "MIT",
          'license_url' => nil,
          'project_url' => nil
        },
        "baz-1.3" => {
          'license' => "BSD",
          'license_url' => nil,
          'project_url' => nil
        },
        "with-hyphens-1.4" => {
          'license' => "MIT",
          'license_url' => nil,
          'project_url' => nil
        }
      },
    })
    expect(validator.pretty_gem_list).to eq([
      {
        :name=>"baz",
        :license=>"BSD",
        :license_url => nil,
        :project_url => nil
      },
      {
        :name=>"foo",
        :license=>"MIT",
        :license_url => nil,
        :project_url => nil
      },
      {
        :name=>"with-hyphens",
        :license=>"MIT",
        :license_url => nil,
        :project_url => nil
        }
      ])
  end

  it 'displays JS libraries in a pretty format without versions' do
    Papers::LicenseValidator.any_instance.stub(:manifest).and_return({
      "javascripts" => {
        "/path/to/foo.js" => {
          'license' => "MIT",
          'license_url' => nil,
          'project_url' => nil
        },
        "/path/to/newrelic.js" => {
          'license' => "New Relic",
          'license_url' => nil,
          'project_url' => nil
        }
      },
      "gems" => {}
    })
    expect(validator.pretty_js_list).to eq([
      {
        :name =>"/path/to/foo.js",
        :license =>"MIT",
        :license_url => nil,
        :project_url => nil
      },
      {
        :name =>"/path/to/newrelic.js",
        :license =>"New Relic",
        :license_url => nil,
        :project_url => nil
      }
    ])
  end

  it 'displays the gem name when the gemspec does not specify a version' do
    gemspec = Papers::Gem.new(name: 'foo')
    expect('foo').to eq(gemspec.name_without_version)
  end

end
