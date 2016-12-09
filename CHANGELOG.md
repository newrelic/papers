# Changelog

## 2.4.1
* Fix problem where missing licenses from gemspecs overrode hand-authored manifest values.

## 2.4.0
* Support `papers --update` to bring manifest up to date with current libraries installed.

## 2.3.0
* Add `config.ignore_npm_dev_dependencies` option to not apply validation to npm devDepdency modules. This is useful if you don't need to consider packages that aren't use in production.

## 2.2.0

* Fix empty npm package name bug. The name of an npm package would be blank when its version was,
  e.g., a git url with no digits anywhere.
* Include package type (Gem, npm package, etc.) in error messages.

## 2.1.0

* Add ISC license to default whitelist

## 2.0.1

* Correct validation of js.erb and coffee.erb files.

## 2.0.0

* Make the `version_whitelisted_license` option to apply to Bower components.
  This is a breaking change since current manifests with whitelisted licenses
  need to be updated to remove the version from their name in the manifest.

## 1.4.0

* Add `config.whitelist_javascript_paths`, a list of paths to exclude from
  JavaScript/CoffeeScript license validation. This is useful if you have
  subdirectories that include build dependencies that won't get shipped to your
  production environment. For example:

  ```ruby
  config.whitelist_javascript_paths << File.join('public', 'javascripts', 'node_modules')
  ```

### 1.3.2

* Add support for CoffeeScript files in your manifest (simply add them to the javascripts list)
* Fix an issue with `papers --generate` erroring out

### 1.3.1

* The previous gem binary was accidentally built without the NPM dependency
  management that was supposed to be included in 1.3.0. Sorry.

## 1.3.0

* Papers now validates NPM packages. This is useful if, for example, you have a
  Rails application that includes a JavaScript app (Ember.js, Angular.js, etc.)

## 1.2.0

* Add a configuration option, `version_whitelisted_license`. When used, it will
  cause gems with a specific license to _ignore versions_. This means that, for
  internally written gems, you don't have to specify a version and repeatedly
  update the license manifest as the gem updates.

## 1.1.0

* Add support for validating the licenses of Bower components (thanks to [@Aughr](https://github.com/aughr))

## 1.0.0 (Initial Release)

* Initial release of Papers. Support for validating the licenses of:
  * Ruby Gems
  * Javascript libraries and files
