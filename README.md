# Papers [![Build Status](https://travis-ci.org/newrelic/papers.svg?branch=master)](https://travis-ci.org/newrelic/papers)

> "Papers, please."

Check that your Ruby project's dependencies are licensed with only the licenses you specify.  **Papers** will validate that your gems and JavaScript files conform to a whitelist of software licenses. Don't get caught flat-footed by the GPL.

## Contents

* [Installation](#installation)
* [Usage](#usage)
* [License](#license)
* [Contributing](#contributing)

## Installation

In your application's Gemfile:

```ruby
gem 'papers'
```

Then, after a `bundle install`, run Papers' installer:

```sh
$ bundle exec papers --generate
Created config/papers_manifest.yml!
```

This creates a YAML file detailing your bundled gems and JavaScript files:

```yaml
# config/papers_manifest.yml
---
gems:
  sqlite3-1.3.7:
    license: MIT
    license_url: https://github.com/luislavena/sqlite3-ruby/blob/master/LICENSE
    project_url: https://github.com/luislavena/sqlite3-ruby

javascripts:
  app/assets/javascripts/application.js:
    license: Unknown
    license_url:
    project_url:
```

## Usage

Configure Papers in your test suite:

```ruby
# spec/spec_helper.rb or test/test_helper.rb
require 'papers'

Papers.configure do |config|
  # A whitelist of accepted licenses. Defaults to:
  #
  # [
  #   'MIT',
  #   'BSD',
  #   'Apache 2.0',
  #   'Apache-2.0',
  #   'LGPLv2.1',
  #   'LGPLv3',
  #   'Ruby',
  #   'Manually Reviewed',
  #   'Unlicensed'
  # ]
  # config.license_whitelist << 'New Relic'

  # You can specify a single license that, when used, ignores the version. Defaults to nil.
  # WARNING: You should only use this for software licensed in house.
  # config.version_whitelisted_license = 'New Relic'

  # The location of your dependency manifest. Defaults to config/papers_manifest.yml
  config.manifest_file = File.join('config', 'papers_manifest.yml')

  # Configures Papers to validate licenses for bundled gems. Defaults to true.
  config.validate_gems = true

  # Configures Papers to validate licenses for included JavaScript and CoffeScript files. Defaults to true.
  config.validate_javascript = true

  # A list of paths where you have included JavaScript and CoffeeScript files. Defaults to:
  #
  # %w[app/assets/javascripts lib/assets/javascripts vendor/assets/javascripts]
  config.javascript_paths << File.join('public', 'javascripts')

  # Configures Papers to validate licenses for bower components. Defaults to false.
  config.validate_bower_components = false

  # Configures where Papers should look for bower components. Each component
  # must have a .bower.json file in its directory for Papers to see it.
  # config.bower_components_path = 'vendor/assets/components'

  # Configures Papers to validate licenses for NPM dependencies. Defaults to false.
  config.validate_npm_packages = false

  # Configures where Papers should look for the package.json file. Defaults to:
  # package.json in the root directory of the project
  config.npm_package_json_path = File.join(Dir.pwd, 'package.json')
end
```

Then, create a test that will validate your dependencies' licenses:

```ruby
# Using RSpec
require 'spec_helper'

describe 'Papers License Validation' do
  subject(:validator) { Papers::LicenseValidator.new }

  it 'knows and is satisfied by all dependency licenses' do
    expect(validator).to be_valid, -> { "License validation failed:\n#{validator.errors.join("\n")}" }
  end
end

# Using Minitest (Test::Unit)
require 'test_helper'

class PapersLicenseValidationTest < ActiveSupport::TestCase
  def test_know_and_be_satisfied_by_all_licenses
    validator = Papers::LicenseValidator.new

    assert validator.valid?, "License validation failed:\n#{validator.errors.join("\n")}"
  end
end
```

Finally, run your test suite!

```sh
$ bundle exec rspec spec/integration/papers_license_validation_spec.rb
.

Failures:

  1) Papers License Validation knows and is satisfied by all dependency licenses
     Failure/Error: expect(validator).to be_valid

       expected: true value
            got: false

       License validator failed: sass-3.2.12 is licensed under GPL, which is not whitelisted

       (compared using ==)
     # ./spec/integration/papers_license_validation_spec.rb:9:in `block (2 levels) in <top (required)>'

Finished in 0.01043 seconds
1 examples, 1 failures
```

## License

The Papers Gem is licensed under the __MIT License__.  See [MIT-LICENSE](https://github.com/newrelic/papers/blob/master/MIT-LICENSE) for full text.

## Contributing

You are welcome to send pull requests to us - however, by doing so you agree that you are granting New Relic a non-exclusive, non-revokable, no-cost license to use the code, algorithms, patents, and ideas in that code in our products if we so choose. You also agree the code is provided as-is and you provide no warranties as to its fitness or correctness for any purpose.
