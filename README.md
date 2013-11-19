
# Papers

"Papers, please."

Checks that your Rails project's dependencies are licensed with only the licenses in a whitelist you specify. Validates the licenses of your gems and JavaScript files, which are listed in a YAML manifest file.

## Usage

0. Add gem to your Gemfile:
```ruby
gem 'papers'
```
1. Generate test
```shell
$ rake papers:generate_test
```
2. Run the test, created in test/integration/papers_license_validation_test.rb
```shell
$ rake test test/integration/papers_license_validation_test.rb
```

## License

The Papers Gem is licensed under the __MIT License__.  See [MIT-LICENSE](https://github.com/newrelic/papers/blob/master/MIT-LICENSE) for full text.

## Contributing

You are welcome to send pull requests to us - however, by doing so you agree that you are granting New Relic a non-exclusive, non-revokable, no-cost license to use the code, algorithms, patents, and ideas in that code in our products if we so choose. You also agree the code is provided as-is and you provide no warranties as to its fitness or correctness for any purpose.
