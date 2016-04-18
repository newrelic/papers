require 'spec_helper'

describe 'Papers' do

  let(:validator) { Papers::LicenseValidator.new }

  it 'validates a manifest with empty values and set of dependencies' do
    allow_any_instance_of(Papers::LicenseValidator).to receive(:manifest).and_return({
      'javascripts' => {},
      'gems' => {}
    })
    allow(Papers::Gem).to receive(:introspected).and_return([])

    expect(validator.valid?).to be_truthy
  end

  it 'detects mismatched gems' do
    allow_any_instance_of(Papers::LicenseValidator).to receive(:manifest).and_return({
      'javascripts' => {},
      'gems' => {
        'foo-1.2' => { 'license' => 'MIT' },
        'baz-1.3' => { 'license' => 'BSD' }
      }
    })

    allow(Bundler).to receive_message_chain(:load, :specs).and_return([
      double(name: 'bar', version: '1.2', licenses: ['MIT']),
      double(name: 'baz', version: '1.3', licenses: ['BSD'])
    ])

    expect(validator.valid?).to be_falsey

    expect(validator.errors).to eq([
      'Gem bar-1.2 is included in the application, but not in the manifest',
      'Gem foo-1.2 is included in the manifest, but not in the application'
    ])

    validator.valid?
  end

  it 'detects mismatched gem versions' do
    allow_any_instance_of(Papers::Configuration).to receive(:validate_javascript?).and_return(false)
    allow_any_instance_of(Papers::LicenseValidator).to receive(:manifest).and_return({
      'javascripts' => {},
      'gems' => {
        'foo-1.2' => { 'license' => 'MIT' },
        'baz-1.3' => { 'license' => 'BSD' }
      }
    })
    allow(Bundler).to receive_message_chain(:load, :specs).and_return([
      double(name: 'foo', version: '1.2', licenses: ['MIT']),
      double(name: 'baz', version: '1.2', licenses: ['BSD'])
    ])

    expect(validator.valid?).to be_falsey

    expect(validator.errors).to eq([
      'Gem baz-1.2 is included in the application, but not in the manifest',
      'Gem baz-1.3 is included in the manifest, but not in the application'
    ])
    validator.valid?
  end

  it 'detects omitted gem versions' do
    allow_any_instance_of(Papers::Configuration).to receive(:validate_javascript?).and_return(false)
    allow_any_instance_of(Papers::LicenseValidator).to receive(:manifest).and_return({
      'javascripts' => {},
      'gems' => {
        'foo' => { 'license' => 'MIT' },
        'baz-1.2' => { 'license' => 'BSD' }
      }
    })
    allow(Bundler).to receive_message_chain(:load, :specs).and_return([
      double(name: 'foo', version: '1.2', licenses: ['MIT']),
      double(name: 'baz', version: '1.2', licenses: ['BSD'])
    ])

    expect(validator).not_to be_valid

    expect(validator.errors).to eq([
      'Gem foo-1.2 is included in the application, but not in the manifest',
      'Gem foo is included in the manifest, but not in the application'
    ])
    validator.valid?
  end

  it 'is OK with matching gem sets' do
    allow_any_instance_of(Papers::LicenseValidator).to receive(:manifest).and_return({
      'javascripts' => {},
      'gems' => {
        'foo-1.2' => { 'license' => 'MIT' },
        'baz-1.2' => { 'license' => 'BSD' }
      }
    })
    allow(Bundler).to receive_message_chain(:load, :specs).and_return([
      double(name: 'foo', version: '1.2', licenses: ['MIT']),
      double(name: 'baz', version: '1.2', licenses: ['BSD'])
    ])

    expect(validator.valid?).to be_truthy
  end

  it 'is OK with whitelisting gem versions on a specific license' do
    allow_any_instance_of(Papers::LicenseValidator).to receive(:manifest).and_return({
      'javascripts' => {},
      'gems' => {
        'foo' => { 'license' => 'MIT' },
        'baz' => { 'license' => 'BSD' }
      }
    })
    allow(Bundler).to receive_message_chain(:load, :specs).and_return([
      double(name: 'foo', version: '1.2', licenses: ['MIT']),
      double(name: 'baz', version: '1.2', licenses: ['BSD'])
    ])
    allow_any_instance_of(Papers::Configuration).to receive(:version_whitelisted_license).and_return('MIT')

    expect(validator).not_to be_valid
    expect(validator.errors).to eq([
      'Gem baz-1.2 is included in the application, but not in the manifest',
      'Gem baz is included in the manifest, but not in the application'
    ])
  end

  it 'is OK with whitelisting specific gems', focus: true do
    allow_any_instance_of(Papers::Configuration).to receive(:package_whitelist).and_return(['foo-1.2'])
    allow_any_instance_of(Papers::LicenseValidator).to receive(:manifest).and_return({
      'javascripts' => {},
      'gems' => {
        'foo-1.2' => { 'license' => 'GPL' },
        'baz-1.3' => { 'license' => 'GPL' }
      }
    })
    allow(Bundler).to receive_message_chain(:load, :specs).and_return([
      double(name: 'foo', version: '1.2', licenses: ['GPL']),
      double(name: 'baz', version: '1.3', licenses: ['GPL'])
    ])

    expect(validator).not_to be_valid

    expect(validator.errors).to eq([
      'Gem baz-1.3 is licensed under GPL, which is not whitelisted'
    ])
  end

  it 'is OK with matching gem sets but complain about a license issue' do
    allow_any_instance_of(Papers::LicenseValidator).to receive(:manifest).and_return({
      'javascripts' => {},
      'gems' => {
        'foo-1.2' => { 'license' => 'MIT' },
        'baz-1.3' => { 'license' => 'GPL' }
      }
    })
    allow(Bundler).to receive_message_chain(:load, :specs).and_return([
      double(name: 'foo', version: '1.2', licenses: ['MIT']),
      double(name: 'baz', version: '1.3', licenses: ['GPL'])
    ])

    expect(validator).not_to be_valid

    expect(validator.errors).to eq([
      'Gem baz-1.3 is licensed under GPL, which is not whitelisted'
    ])
  end

  it 'displays gem licenses in a pretty format without versions' do
    allow_any_instance_of(Papers::LicenseValidator).to receive(:manifest).and_return({
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

  it 'displays npm package name correctly when it ends in a hyphen' do
    # package names rarely (if ever) end in a hyphen, but the names returned by manifest end with a
    # hyphen if the version is determined to be blank, which happens when there are no digits in the
    # version string (due to, e.g., a git URL without a hash in it). See
    # NpmPackage.full_introspected_entries.
    allow_any_instance_of(Papers::Configuration).to receive(:validate_npm_packages?).and_return(true)

    allow_any_instance_of(Papers::LicenseValidator).to receive(:manifest).and_return({
      'javascripts' => {},
      'gems' => {},
      'npm_packages' => {
        'foo-' => {
          'license' => 'MIT',
          'license_url' => nil,
          'project_url' => nil
        }
      }
    })

    expect(validator.pretty_npm_package_list).to eq([
      {
        name: 'foo',
        license: 'MIT',
        license_url: nil,
        project_url: nil
      }
    ])
  end

  it 'displays JS libraries in a pretty format without versions' do
    allow_any_instance_of(Papers::LicenseValidator).to receive(:manifest).and_return({
      'javascripts' => {
        '/path/to/foo.js' => {
          'license' => 'MIT',
          'license_url' => nil,
          'project_url' => nil
        },
        '/path/to/bar.coffee' => {
          'license' => 'MIT',
          'license_url' => nil,
          'project_url' => nil
        },
        '/path/to/newrelic.js.erb' => {
          'license' => 'New Relic',
          'license_url' => nil,
          'project_url' => nil
        },
        '/path/to/newrelic.js.coffee' => {
          'license' => 'New Relic',
          'license_url' => nil,
          'project_url' => nil
        }
      },
      'gems' => {}
    })

    expect(validator.pretty_js_list).to contain_exactly(
      {
        :name =>'/path/to/foo.js',
        :license =>'MIT',
        :license_url => nil,
        :project_url => nil
      },
      {
        :name =>'/path/to/bar.coffee',
        :license =>'MIT',
        :license_url => nil,
        :project_url => nil
      },
      {
        :name =>'/path/to/newrelic.js.erb',
        :license =>'New Relic',
        :license_url => nil,
        :project_url => nil
      },
      {
        :name =>'/path/to/newrelic.js.coffee',
        :license =>'New Relic',
        :license_url => nil,
        :project_url => nil
      }
    )
  end

  it 'displays bower component licenses in a pretty format without versions' do
    allow_any_instance_of(Papers::Configuration).to receive(:validate_bower_components?).and_return(true)

    allow_any_instance_of(Papers::LicenseValidator).to receive(:manifest).and_return({
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

  it 'skips bower versions for whitelisted licenses' do
    allow_any_instance_of(Papers::Configuration).to receive(:version_whitelisted_license).and_return('Whitelist')

    allow(Papers::BowerComponent).to receive(:bower_json_entries).and_return([
      {
        'name' => 'foo',
        '_release' => '1.2',
        'license' => 'MIT',
      },
      {
        'name' => 'baz',
        '_release' => '1.3',
        'license' => 'BSD',
      },
      {
        'name' => 'internal-thing',
        '_release' => '1.5',
        'license' => 'Whitelist',
      },
    ])

    names = Papers::BowerComponent.introspected
    expect(names).to eq([
      'foo-1.2',
      'baz-1.3',
      'internal-thing'
    ])
  end

  it 'displays npm package licenses in a pretty format without versions' do
    allow_any_instance_of(Papers::Configuration).to receive(:validate_npm_packages?).and_return(true)

    allow_any_instance_of(Papers::LicenseValidator).to receive(:manifest).and_return({
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

  it 'is OK with whitelisting javascript javascript_paths' do
    # contents of javascript dir and no gems
    allow(Dir).to receive(:glob).and_return([
      'app/javascripts/node_modules/should_be_whitelisted.js',
      'app/javascripts/test.js'
    ])

    allow(Papers::Gem).to receive(:introspected).and_return([])

    allow_any_instance_of(Papers::LicenseValidator).to receive(:manifest).and_return({
      'javascripts' => {
        'app/javascripts/test.js' => {
          'license' => 'MIT',
          'license_url' => nil,
          'project_url' => nil
        }
      },
      'gems' => {}
    })
    allow_any_instance_of(Papers::Configuration).to receive(:javascript_paths).and_return(['app/javascripts/'])

    # whitelist this directory
    allow_any_instance_of(Papers::Configuration).to receive(:whitelist_javascript_paths).and_return(['app/javascripts/node_modules'])

    expect(Papers::Javascript.introspected).to_not include('app/javascripts/node_modules/should_be_whitelisted.js')
    expect(validator).to be_valid
  end

  describe "Command Line" do
    def silently
      vblevel = $VERBOSE 
      $VERBOSE = nil
      yield
    ensure
      $VERBOSE = vblevel
    end
    
    before do
      @old_argv = ARGV
    end
    after do
      silently { ARGV = @old_argv }
    end
    it "runs the papers command and prints out help" do
      silently { ARGV = %w[-h] }
      cli = Papers::CLI.new
      expect(cli).to receive(:puts) do |opts|
        expect(opts.to_s).to match /^Usage: papers.*/
      end
      cli.run
    end
  end


end
