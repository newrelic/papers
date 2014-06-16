require 'bundler/setup'
require 'rspec'
require_relative '../lib/papers'

describe 'Papers' do

  let(:validator) { Papers::LicenseValidator.new }

  it 'validates a manifest with empty values and set of dependencies' do
    Papers::LicenseValidator.any_instance.stub(:manifest).and_return({
      'javascripts' => {},
      'gems' => {}
    })
    Papers::Gem.stub(:introspected).and_return([])

    expect(validator.valid?).to be_truthy
  end

  it 'detects mismatched gems' do
    Papers::LicenseValidator.any_instance.stub(:manifest).and_return({
      'javascripts' => {},
      'gems' => {
        'foo-1.2' => { 'license' => 'MIT' },
        'baz-1.3' => { 'license' => 'BSD' }
      }
    })
    Bundler.stub_chain(:load, :specs).and_return([
      double(name: 'bar', version: '1.2', licenses: ['MIT']),
      double(name: 'baz', version: '1.3', licenses: ['BSD'])
    ])

    expect(validator.valid?).to be_falsey

    expect(validator.errors).to eq([
      'bar-1.2 is included in the application, but not in the manifest',
      'foo-1.2 is included in the manifest, but not in the application'
    ])

    validator.valid?
  end

  it 'detects mismatched gem versions' do
    Papers::Configuration.any_instance.stub(:validate_javascript?).and_return(false)

    Papers::LicenseValidator.any_instance.stub(:manifest).and_return({
      'javascripts' => {},
      'gems' => {
        'foo-1.2' => { 'license' => 'MIT' },
        'baz-1.3' => { 'license' => 'BSD' }
      }
    })
    Bundler.stub_chain(:load, :specs).and_return([
      double(name: 'foo', version: '1.2', licenses: ['MIT']),
      double(name: 'baz', version: '1.2', licenses: ['BSD'])
    ])

    expect(validator.valid?).to be_falsey

    expect(validator.errors).to eq([
      'baz-1.2 is included in the application, but not in the manifest',
      'baz-1.3 is included in the manifest, but not in the application'
    ])
    validator.valid?
  end

  it 'detects omitted gem versions' do
    Papers::Configuration.any_instance.stub(:validate_javascript?).and_return(false)

    Papers::LicenseValidator.any_instance.stub(:manifest).and_return({
      'javascripts' => {},
      'gems' => {
        'foo' => { 'license' => 'MIT' },
        'baz-1.2' => { 'license' => 'BSD' }
      }
    })
    Bundler.stub_chain(:load, :specs).and_return([
      double(name: 'foo', version: '1.2', licenses: ['MIT']),
      double(name: 'baz', version: '1.2', licenses: ['BSD'])
    ])

    expect(validator).not_to be_valid

    expect(validator.errors).to eq([
      'foo-1.2 is included in the application, but not in the manifest',
      'foo is included in the manifest, but not in the application'
    ])
    validator.valid?
  end

  it 'is OK with matching gem sets' do
    Papers::LicenseValidator.any_instance.stub(:manifest).and_return({
      'javascripts' => {},
      'gems' => {
        'foo-1.2' => { 'license' => 'MIT' },
        'baz-1.2' => { 'license' => 'BSD' }
      }
    })
    Bundler.stub_chain(:load, :specs).and_return([
      double(name: 'foo', version: '1.2', licenses: ['MIT']),
      double(name: 'baz', version: '1.2', licenses: ['BSD'])
    ])

    expect(validator.valid?).to be_truthy
  end

  it 'is OK with whitelisting gem versions on a specific license' do
    Papers::LicenseValidator.any_instance.stub(:manifest).and_return({
      'javascripts' => {},
      'gems' => {
        'foo' => { 'license' => 'MIT' },
        'baz' => { 'license' => 'BSD' }
      }
    })
    Bundler.stub_chain(:load, :specs).and_return([
      double(name: 'foo', version: '1.2', licenses: ['MIT']),
      double(name: 'baz', version: '1.2', licenses: ['BSD'])
    ])
    Papers::Configuration.any_instance.stub(:version_whitelisted_license).and_return('MIT')

    expect(validator).not_to be_valid
    expect(validator.errors).to eq([
      'baz-1.2 is included in the application, but not in the manifest',
      'baz is included in the manifest, but not in the application'
    ])
  end

  it 'is OK with matching gem sets but complain about a license issue' do
    Papers::LicenseValidator.any_instance.stub(:manifest).and_return({
      'javascripts' => {},
      'gems' => {
        'foo-1.2' => { 'license' => 'MIT' },
        'baz-1.3' => { 'license' => 'GPL' }
      }
    })
    Bundler.stub_chain(:load, :specs).and_return([
      double(name: 'foo', version: '1.2', licenses: ['MIT']),
      double(name: 'baz', version: '1.3', licenses: ['GPL'])
    ])

    expect(validator).not_to be_valid

    expect(validator.errors).to eq([
      'baz-1.3 is licensed under GPL, which is not whitelisted'
    ])
  end

  it 'displays gem licenses in a pretty format without versions' do
    Papers::LicenseValidator.any_instance.stub(:manifest).and_return({
      'javascripts' => {},
      'gems' => {
        'foo-1.2'          => { 'license' => 'MIT' },
        'baz-1.3'          => { 'license' => 'BSD' },
        'with-hyphens-1.4' => { 'license' => 'MIT' }
      },
    })

    expect(validator.pretty_gem_list).to eq([
      {
        name: 'baz',
        license: 'BSD',
        license_url: nil,
        project_url: nil
      },
      {
        name: 'foo',
        license: 'MIT',
        license_url: nil,
        project_url: nil
      },
      {
        name: 'with-hyphens',
        license: 'MIT',
        license_url: nil,
        project_url: nil
      }
    ])
  end

  it 'displays JS libraries in a pretty format without versions' do
    Papers::LicenseValidator.any_instance.stub(:manifest).and_return({
      'javascripts' => {
        '/path/to/foo.js' => {
          'license' => 'MIT',
          'license_url' => nil,
          'project_url' => nil
        },
        '/path/to/newrelic.js' => {
          'license' => 'New Relic',
          'license_url' => nil,
          'project_url' => nil
        }
      },
      'gems' => {}
    })

    expect(validator.pretty_js_list).to eq([
      {
        :name =>'/path/to/foo.js',
        :license =>'MIT',
        :license_url => nil,
        :project_url => nil
      },
      {
        :name =>'/path/to/newrelic.js',
        :license =>'New Relic',
        :license_url => nil,
        :project_url => nil
      }
    ])
  end

  it 'displays bower component licenses in a pretty format without versions' do
    Papers::Configuration.any_instance.stub(:validate_bower_components?).and_return(true)

    Papers::LicenseValidator.any_instance.stub(:manifest).and_return({
      'javascripts' => {},
      'gems' => {},
      'bower_components' => {
        'foo-1.2' => {
          'license' => 'MIT',
          'license_url' => nil,
          'project_url' => nil
        },
        'baz-1.3' => {
          'license' => 'BSD',
          'license_url' => nil,
          'project_url' => nil
        },
        'with-hyphens-1.4' => {
          'license' => 'MIT',
          'license_url' => nil,
          'project_url' => nil
        }
      },
    })

    expect(validator.pretty_bower_component_list).to eq([
      {
        name: 'baz',
        license: 'BSD',
        license_url: nil,
        project_url: nil
      },
      {
        name: 'foo',
        license: 'MIT',
        license_url: nil,
        project_url: nil
      },
      {
        name: 'with-hyphens',
        license: 'MIT',
        license_url: nil,
        project_url: nil
      }
    ])
  end

  it 'displays npm package licenses in a pretty format without versions' do
    Papers::Configuration.any_instance.stub(:validate_npm_packages?).and_return(true)

    Papers::LicenseValidator.any_instance.stub(:manifest).and_return({
      'javascripts' => {},
      'gems' => {},
      'npm_packages' => {
        'foo-1.2' => {
          'license' => 'MIT',
          'license_url' => nil,
          'project_url' => nil
        },
        'baz-1.3' => {
          'license' => 'BSD',
          'license_url' => nil,
          'project_url' => nil
        },
        'with-hyphens-1.4' => {
          'license' => 'MIT',
          'license_url' => nil,
          'project_url' => nil
        }
      },
    })

    expect(validator.pretty_npm_package_list).to eq([
      {
        name: 'baz',
        license: 'BSD',
        license_url: nil,
        project_url: nil
      },
      {
        name: 'foo',
        license: 'MIT',
        license_url: nil,
        project_url: nil
      },
      {
        name: 'with-hyphens',
        license: 'MIT',
        license_url: nil,
        project_url: nil
      }
    ])
  end

  it 'displays the gem name when the gemspec does not specify a version' do
    gemspec = Papers::Gem.new(name: 'foo')
    expect('foo').to eq(gemspec.name_without_version)
  end
end
