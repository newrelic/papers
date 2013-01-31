require 'rubygems'
require 'bundler'
Bundler.setup

require 'test/unit'
require 'shoulda'

require 'papers'

module Papers
class DependencyLicenseValidatorTest < Test::Unit::TestCase
  should "detect mismatched gems" do
    validator = DependencyLicenseValidator.new
    validator.expects(:validate_js)

    validator.expects(:manifest).returns({
      "javascripts" => {},
      "gems" => {"foo-1.2" => {'license' => "MIT", 'license_url' => nil, 'project_url' => nil}, "baz-1.3" => {'license' => "BSD", 'license_url' => nil, 'project_url' => nil} }
    }).at_least_once
    DependencyLicenseValidator::GemSpec.expects(:introspected).returns(["bar-1.2", "baz-1.3"]).at_least_once

    assert !validator.valid?, "should not be valid"
    assert_equal ["bar-1.2 is in the app, but not in the manifest", "foo-1.2 is in the manifest, but not in the app"], validator.errors
  end

  should "detect mismatched gem versions" do
    validator = DependencyLicenseValidator.new
    validator.expects(:validate_js)

    validator.expects(:manifest).returns({
      "javascripts" => {},
      "gems" => {"foo-1.2" => {'license' => "MIT", 'license_url' => nil, 'project_url' => nil} , "baz-1.3" => {'license' => "BSD", 'license_url' => nil, 'project_url' => nil} },
    }).at_least_once
    DependencyLicenseValidator::GemSpec.expects(:introspected).returns(["foo-1.2", "baz-1.2"]).at_least_once

    assert !validator.valid?, "should not be valid"
    assert_equal ["baz-1.2 is in the app, but not in the manifest", "baz-1.3 is in the manifest, but not in the app"], validator.errors
  end

  should "be OK with matching gem sets" do
    validator = DependencyLicenseValidator.new
    validator.expects(:validate_js)

    validator.expects(:manifest).returns({
      "javascripts" => {},
      "gems" => {"foo-1.2" => {'license' => "MIT", 'license_url' => nil, 'project_url' => nil}, "baz-1.3" => {'license' => "BSD", 'license_url' => nil, 'project_url' => nil}},
    }).at_least_once
    DependencyLicenseValidator::GemSpec.expects(:introspected).returns(["foo-1.2", "baz-1.3"]).at_least_once

    assert validator.valid?, "should be valid"
    assert_equal [], validator.errors
  end

  should "be OK with matching gem sets but complain about a license issue" do
    validator = DependencyLicenseValidator.new
    validator.expects(:validate_js)

    validator.expects(:manifest).returns({
      "javascripts" => {},
      "gems" => {"foo-1.2" => {'license' => "MIT", 'license_url' => nil, 'project_url' => nil}, "baz-1.3" => {'license' => "GPL", 'license_url' => nil, 'project_url' => nil}},
    }).at_least_once
    DependencyLicenseValidator::GemSpec.expects(:introspected).returns(["foo-1.2", "baz-1.3"]).at_least_once

    assert !validator.valid?, "should be valid"
    assert_equal ["baz-1.3 is licensed under GPL, which is not acceptable"], validator.errors
  end

  should "allow a license_url in the manifest definition" do
    validator = DependencyLicenseValidator.new
    validator.expects(:validate_js)

    validator.expects(:manifest).returns({
                                             "javascripts" => {},
                                             "gems" => {"foo-1.2" => {'license' => "MIT", 'license_url' => nil, 'project_url' => nil}, "baz-1.3" => {'license' => "BSD", 'license_url' => nil, 'project_url' => nil}},
                                         }).at_least_once
    DependencyLicenseValidator::GemSpec.expects(:introspected).returns(["bar-1.2", "baz-1.3"]).at_least_once

    assert !validator.valid?, "should not be valid"
    assert_equal ["bar-1.2 is in the app, but not in the manifest", "foo-1.2 is in the manifest, but not in the app"], validator.errors
  end

  should "display gem licenses in a pretty format without versions" do
    validator = DependencyLicenseValidator.new
    validator.expects(:manifest).returns({
                                             "javascripts" => {},
                                             "gems" => {"foo-1.2" => {'license' => "MIT", 'license_url' => nil, 'project_url' => nil}, "baz-1.3" => {'license' => "Manually reviewed", 'license_url' => nil, 'project_url' => nil}, "with-hyphens-1.4" => {'license' => "MIT", 'license_url' => nil, 'project_url' => nil}},
                                         }).at_least_once
    assert_equal [{:name=>"baz", :license=>"Other", :license_url => nil, :project_url => nil},
                  {:name=>"foo", :license=>"MIT", :license_url => nil, :project_url => nil},
                  {:name=>"with-hyphens", :license=>"MIT", :license_url => nil, :project_url => nil}], validator.pretty_gem_list
  end

  should "display JS libraries in a pretty format without versions" do
    validator = DependencyLicenseValidator.new
    validator.expects(:manifest).returns({
                                             "javascripts" => {"/path/to/foo.js" => {'license' => "MIT", 'license_url' => nil, 'project_url' => nil}, "/path/to/newrelic.js" => {'license' => "New Relic", 'license_url' => nil, 'project_url' => nil}},
                                             "gems" => {}
                                         }).at_least_once
    assert_equal [{:name=>"/path/to/foo.js", :license=>"MIT", :license_url => nil, :project_url => nil},
                  {:name=>"/path/to/newrelic.js", :license=>"New Relic", :license_url => nil, :project_url => nil}],
                 validator.pretty_js_list
  end

  should "display the gem name when the gemspec does not specify a version" do
    gemspec = DependencyLicenseValidator::GemSpec.new(name: 'foo')
    assert_equal 'foo', gemspec.name_without_version
  end

end
end
