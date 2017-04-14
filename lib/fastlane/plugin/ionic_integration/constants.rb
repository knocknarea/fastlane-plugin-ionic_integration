module Fastlane
  module IonicIntegration
    IONIC_IOS_BUILD_PATH = "platforms/ios"
    DEFAULT_IOS_VERSION = "9.0"

    IONIC_CONFIG_PATH = "fastlane/ionic/config"
    IONIC_IOS_CONFIG_PATH = IONIC_CONFIG_PATH + "/ios"
    IONIC_IOS_CONFIG_UITESTS_PATH = IONIC_IOS_CONFIG_PATH + "/ui-tests"

    IONIC_DEFAULT_UNIT_TEST_NAME = "ui-snapshots"
  end
end
