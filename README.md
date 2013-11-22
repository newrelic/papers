
# Papers

"Papers, please."

Checks that your Rails project's dependencies are licensed with only the licenses in a whitelist you specify. Validates the licenses of your gems and JavaScript files, which are listed in a YAML manifest file.

## Usage

add gem
create dependency manifest
run test


0. Add gem to your Gemfile:
```
gem 'papers'
```
1. Create Dependency Manifest (see below for example)
```
$ touch ./config/dependency_manifest.yml
```
2. Generate validation test (see below for example)

3.Run the test, created in test/integration/papers_license_validation_test.rb
````
$ rake test test/integration/papers_license_validation_test.rb
```
...
  1) Failure:
test_know_and_be_satisfied_by_all_licenses(PapersLicenseValidationTest)
License validator failed:
haml-4.0.0 is in the app, but not in the manifest
...
```

### Validation Test Example

```
# => test/integration/papers_license_validation_test.rb

require 'test_helper'
require 'papers'

class PapersLicenseValidationTest < ActiveSupport::TestCase
  def test_know_and_be_satisfied_by_all_licenses
    validator = Papers::DependencyLicenseValidator.new
    assert validator.valid?, "License validator failed:\n#{validator.errors.join("\n")}"
  end
end
```

### dependency_manifest.yml Example
[see dependency_manifest.yml.sample for Rails 3.2](https://github.com/newrelic/papers/blob/master/templates/dependency_manifest.yml.sample)
```
---
gems:
  sqlite3-1.3.7:
    license: MIT
    license_url: https://github.com/luislavena/sqlite3-ruby
    project_url: https://github.com/luislavena/sqlite3-ruby/blob/master/LICENSE

javascripts:
  app/assets/javascripts/application.js:
    license: New Relic
    license_url: http://newrelic.com
    project_url: http://newrelic.com
```

## License

The Papers Gem is licensed under the __MIT License__.  See [MIT-LICENSE](https://github.com/newrelic/papers/blob/master/MIT-LICENSE) for full text.

## Contributing

You are welcome to send pull requests to us - however, by doing so you agree that you are granting New Relic a non-exclusive, non-revokable, no-cost license to use the code, algorithms, patents, and ideas in that code in our products if we so choose. You also agree the code is provided as-is and you provide no warranties as to its fitness or correctness for any purpose.
