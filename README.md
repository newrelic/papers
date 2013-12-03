# Papers

> "Papers, please."

Check that your Ruby/Rails project's dependencies are licensed with only the licenses you specify.  **Papers** will validate that your gems and JavaScript files conform to a whitelist of software licenses. Don't get caught flat-footed by the GPL.

# Contents
 * [Usage](#usage)
 * [Validations](#validations)
 * [Configuration](#configuration)
 * [Structure of Dependency Manifest](#dependency-manifest-structure)
 * [License](#license)
 * [Contributing](#contributing)


# Usage

tl;dr -- add gem, generate dependency manifest, run spec

### 0. Add gem to Gemfile

```
gem 'papers'
```
### 1. Generate Dependency Manifest from your bundled gems and JS

```
$ papers
```
### 2. Create [Validation Spec](#testing-with-rspec)

### 3. Run the specs

```
$ rake spec spec/integration/papers_license_validation_spec.rb
...
Failures:

  1) Papers License Validation finds no errors during license validation
     Failure/Error: expect(validator.errors).to eq([])

       expected: []
            got: ["sass-3.2.12 is licensed under GPL, which is not whitelisted"]

       (compared using ==)
     # ./spec/integration/papers_license_validation_spec.rb:14:in `block (2 levels) in <top (required)>'

  2) Papers License Validation knows and is satisfied by all dependency licenses
     Failure/Error: expect(validator.valid?).to be_true
       expected: true value
            got: false
     # ./spec/integration/papers_license_validation_spec.rb:9:in `block (2 levels) in <top (required)>'

Finished in 0.01043 seconds
2 examples, 2 failures
...
```

# Validations

## testing with RSpec

```
# => spec/integration/papers_license_validation_spec.rb

require 'spec_helper'
require 'papers'

describe 'Papers License Validation' do

  let(:validator) { Papers::LicenseValidator.new }

  it 'knows and is satisfied by all dependency licenses' do
    expect(validator.valid?).to be_true
  end

  it 'finds no errors during license validation' do
    validator.valid?
    expect(validator.errors).to eq([])
  end
end
```

## testing with MiniTest

```
# => test/integration/papers_license_validation_test.rb

require 'test_helper'
require 'papers'

class PapersLicenseValidationTest < ActiveSupport::TestCase
  def test_know_and_be_satisfied_by_all_licenses
    validator = Papers::LicenseValidator.new

    assert validator.valid?, "License validator failed:\n#{validator.errors.join("\n")}"

    assert_equal validator.errors, []
  end
end
```

# Configuration

The default whitelist allows for permissive licensing for proprietary or commercial usage while avoiding strong copyleft licenses.

```
@license_whitelist = [
  'MIT',
  'BSD',
  'Apache 2.0',
  'Apache-2.0',
  'LGPLv2.1',
  'LGPLv3',
  'Ruby',
  'Manually Reviewed',
  'Unlicensed'
]
```

## Available configuration options

To configure the Papers gem, pass options to ```Papers.configure``` before initialization of LicenseValidator:

```
Papers.configure do |c|
  c.license_whitelist << 'New Relic'
  c.manifest_file = File.join('some','other','dependency_manifest.yml')
  c.validate_gems = true
  c.validate_javascript = true
  c.javascript_paths << File.join('some','other','javascripts')
end

validator = Papers::LicenseValidator.new
...
```

# Dependency Manifest structure

```
# => config/papers_manifest.yml
---
gems:
  sqlite3-1.3.7:
    license: MIT
    license_url: https://github.com/luislavena/sqlite3-ruby
    project_url: https://github.com/luislavena/sqlite3-ruby/blob/master/LICENSE
...

javascripts:
  app/assets/javascripts/application.js:
    license: New Relic
    license_url: http://newrelic.com
    project_url: http://newrelic.com
```

# License

The Papers Gem is licensed under the __MIT License__.  See [MIT-LICENSE](https://github.com/newrelic/papers/blob/master/MIT-LICENSE) for full text.

# Contributing

You are welcome to send pull requests to us - however, by doing so you agree that you are granting New Relic a non-exclusive, non-revokable, no-cost license to use the code, algorithms, patents, and ideas in that code in our products if we so choose. You also agree the code is provided as-is and you provide no warranties as to its fitness or correctness for any purpose.
