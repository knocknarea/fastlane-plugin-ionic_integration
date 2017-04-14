# ionic_integration plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-ionic_integration)

## Getting Started

**NOTE** This is hot off the press and I am still testing it locally, so hang tight

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-ionic_integration`, add it to your project by running:

```bash
fastlane add_plugin ionic_integration
```

## About ionic_integration

Integrating Fastlane with Ionic Generated Projects

**Note to author:** Add a more detailed description about this plugin here. If your plugin contains multiple actions, make sure to mention them here.

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`.

To create a sample test you can add a lane like so:

lane :setup_tests do
    ionic_ios_config_snapshot(
      ionic_scheme_name: "blah-blah"
    )

This will create a folder **fastlane/ionic/config/ios/ui-tests/blah-blah**

In this folder will be the standard test files that you would expect for a UI Unit Test, Info.plist, Fastlane SWIFT file and a sample Unit Test ui-snapshots.swift

**ionic_ios_config_snapshot** also executes the *ionic_config_snapshot* action to retrofit this unit test configuration into any existing XCode Project


## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).

