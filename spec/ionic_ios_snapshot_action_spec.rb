require 'pp'
require 'fakefs/spec_helpers'
require 'fakefs'

describe Fastlane::Actions::IonicIosSnapshotAction do
  describe '#run' do
    it 'Finds All Preconfigured UI Tests' do
      FakeFS.with_fresh do
        #
        # Create fake directories
        #
        resources_path = File.dirname(__FILE__) + "/resources/platforms/ios"

        FakeFS::FileSystem.clone(resources_path, Fastlane::IonicIntegration::IONIC_IOS_BUILD_PATH.to_s)
        FakeFS::FileSystem.clone("#{Fastlane::Helper::IonicIntegrationHelper::IOS_RESOURCES_PATH}/#{Fastlane::IonicIntegration::IONIC_DEFAULT_UNIT_TEST_NAME}")

        Fastlane::Helper::IonicIntegrationHelper.copy_ios_sample_tests("first-test")
        Fastlane::Helper::IonicIntegrationHelper.copy_ios_sample_tests("second-test")

        expect(Fastlane::Actions::IonicIosSnapshotAction).to receive(:generate_xcode_unit_test).twice.and_call_original

        Fastlane::Actions::IonicIosSnapshotAction.run(
          ionic_ios_xcode_path: Fastlane::Helper::IonicIntegrationHelper.find_default_ios_xcode_workspace,
          ionic_min_target_ios: Fastlane::IonicIntegration::DEFAULT_IOS_VERSION,
          team_id: "ABC1234",
          bundle_id: "ie.lv.test.bundle"
        )
      end
    end

    it 'Raise if no options specified' do
      expect do
        Fastlane::Actions::IonicIosSnapshotAction.run(nil)
      end.to raise_error(FastlaneCore::Interface::FastlaneError)
    end
  end
end
