require 'pp'
require 'fakefs/spec_helpers'
require 'fakefs'
require 'fastlane/plugin/ionic_integration/constants'

describe Fastlane::Helper::IonicIntegrationHelper do
  include FakeFS::SpecHelpers::All
  describe '#copy_ios_ui_test_code' do
    it 'should copy over sample files' do
      FakeFS.with_fresh do
        src = "#{Fastlane::Helper::IonicIntegrationHelper::IOS_RESOURCES_PATH}/#{Fastlane::IonicIntegration::IONIC_DEFAULT_UNIT_TEST_NAME}"
        dest = "./tests/copytest/ui-snapshots"
        FileUtils.mkdir_p(src)
        FileUtils.touch(src + "/Info.plist")

        expect(FileUtils).to receive(:cp_r).with(src + "/.", dest).once.and_call_original

        Fastlane::Helper::IonicIntegrationHelper.copy_ios_ui_test_code(src, dest)
      end
    end

    it 'should not copy over sample files, src does not exist' do
      FakeFS.with_fresh do
        src = "../fastlane/plugin/ionic_integration/resources/ios/ui-snapshots"
        dest = "./tests/copytest"

        expect do
          Fastlane::Helper::IonicIntegrationHelper.copy_ios_ui_test_code(src, dest)
        end.to raise_error(FastlaneCore::Interface::FastlaneError)
      end
    end
  end

  describe '#copy_ios_sample_tests' do
    it 'should create sample' do
      FakeFS.with_fresh do
        FakeFS::FileSystem.clone("#{Fastlane::Helper::IonicIntegrationHelper::IOS_RESOURCES_PATH}/#{Fastlane::IonicIntegration::IONIC_DEFAULT_UNIT_TEST_NAME}")
        # FileUtils.mkdir_p "#{Fastlane::IonicIntegration::IONIC_IOS_CONFIG_UITESTS_PATH}/my-sample"

        expected_path = "#{Fastlane::IonicIntegration::IONIC_IOS_CONFIG_UITESTS_PATH}/my-sample"

        Fastlane::Helper::IonicIntegrationHelper.copy_ios_sample_tests("my-sample")

        expect(Dir.exist?(expected_path)).to be true
        expect(File.exist?(expected_path + "/Info.plist")).to be true
      end
    end
  end
end
