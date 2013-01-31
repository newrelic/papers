namespace :papers do
  desc "Generate a test that validates the licenses used by an app's libraries against a whitelist"
  task :generate_test do
    test_file = "test/integration/papers_license_validation_test.rb"
    unless File.exists?(test_file)
      test = <<'EOT'
require 'test_helper'
require 'papers'
class PapersLicenseValidationTest < ActiveSupport::TestCase
  def test_know_and_be_satisfied_by_all_licenses
    validator = Papers::DependencyLicenseValidator.new
    assert validator.valid?, "License validator failed:\n#{validator.errors.join("\n")}"
  end
end
EOT
      File.open(test_file, "w+").write(test)
    end
  end
end
