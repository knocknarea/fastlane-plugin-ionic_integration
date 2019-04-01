require 'xcodeproj'

module Fastlane
  module Actions
    class IonicIosSnapshotAction < Action
      def self.run(params)
        UI.message "Configuring Xcode with UI Tests Located in #{IonicIntegration::IONIC_IOS_CONFIG_UITESTS_PATH}/**"

        (!params.nil? && !params[:ionic_ios_xcode_path].nil?) || UI.user_error!("Mandatory parameter :ionic_ios_xcode_path not specified")

        #
        # Deduce the name of the xcode project we are looking for...
        #
        xcode_project = params[:ionic_ios_xcode_path]
        target_os = params[:ionic_min_target_ios]
        team_id = params[:team_id]
        bundle_id = params[:bundle_id]

        File.exist?(xcode_project) || UI.user_error!("Xcode Project #{xcode_project} does not exist!")
        #
        # Find all preconfigured UI Unit Tests
        #
        schemes = Dir.glob("#{IonicIntegration::IONIC_IOS_CONFIG_UITESTS_PATH}/*/").reject do |d|
          d =~ /^\.{1,2}$/
        end

        UI.message "Found #{schemes}..."
        schemes.each do |scheme_path|
          # UI.message("Processing Test Scheme #{scheme_path}")
          generate_xcode_unit_test(scheme_path, xcode_project, team_id, bundle_id, target_os)
        end
      end

      def self.generate_xcode_unit_test(config_folder, xcode_project_path, team_id, bundle_id, target_os)
        scheme_name = File.basename(config_folder)
        xcode_folder = File.dirname(xcode_project_path)
        project_name = File.basename(xcode_project_path, ".xcodeproj")

        UI.message("Setting up #{scheme_name} as UI Unit Test folder and Scheme in #{xcode_folder} for Xcode Project #{project_name}")

        proj = Xcodeproj::Project.open(xcode_project_path) || UI.user_error!("Unable to Open Xcode Project #{xcode_project_path}")

        UI.message("Xcode Project is Version #{proj.root_object.compatibility_version} Compatible")
        #
        # Find existing Target and remove it
        #
        target = nil
        proj.targets.each do |t|
          next unless t.name == scheme_name
          UI.important "Found existing Target #{t.name}. Will be replaced."
          target = t
          break
        end

        #
        # Find existing code group or unit tests and remove if needed.
        #
        snap_group = nil
        proj.groups.each do |g|
          next unless g.name == scheme_name
          g.clear
          snap_group = g
          UI.important "Found existing Code Group #{g.name}. Will be replaced."
          break
        end

        #
        # Remove existing targets and groups if required.
        #
        target.nil? || target.remove_from_project
        snap_group.nil? || snap_group.remove_from_project

        target = nil
        snap_group = nil

        #
        # Ok, let's rock and roll
        #
        UI.message "Creating UI Test Group #{scheme_name} for snapshots testing"
        snap_group = proj.new_group(scheme_name.to_s, File.absolute_path(config_folder), '<absolute>')

        UI.message "Finding Main Target (of the Project)..."
        main_target = nil
        proj.root_object.targets.each do |t|
          if t.name == project_name
            UI.message "Found main target as #{t.name}"
            main_target = t
          end
        end

        main_target || UI.user_error!("Unable to locate Main Target for Ionic App in #{project_name}")

        # Create a product for our ui unit test
        product_ref_name = scheme_name + '.xctest'
        proj.products_group.files.each do |ref|
          if ref.path == product_ref_name
            UI.message "Removing old #{ref.path}"
            ref.remove_from_project
          end
        end

        # product_ref.nil? || product_ref.remove_from_project

        # product_ref = proj.products_group.new_reference(product_ref_name, :built_products)

        target = Xcodeproj::Project::ProjectHelper.new_target(proj, :ui_test_bundle,
                                                              scheme_name, :ios, target_os, proj.products_group, :swift)

        product_ref = proj.products_group.find_file_by_path(product_ref_name)
        target.product_reference = product_ref

        UI.message "Adding Main Target Dependency: " + main_target.to_s
        target.add_dependency(main_target)

        # We need to save here for some reason... xcodeproj?
        proj.save

        UI.message "Adding Pre-Configured UI Unit Tests (*.plist and *.swift) to Test Group #{scheme_name}"
        files = []

        # Link our fastlane configured UI Unit Tests into the project
        Dir["#{config_folder}/*.plist", "#{config_folder}/*.swift"].each do |file|
          UI.message "Adding UI Test Source #{file}"
          files << snap_group.new_reference(File.absolute_path(file), '<absolute>')
        end

        target.add_file_references(files)

        UI.message "Configuring Project Metadata..."

        # We may need to switch here on compatibility versions, this is for Xcode 8.0
        # Fasten your seatbelts, it gets bumpy from here on in..
        target_config = {
            CreatedOnToolsVersion: "8.2",
                  DevelopmentTeam: team_id,
                  ProvisioningStyle: "Automatic",
                  TestTargetID: main_target.uuid
        }

        if proj.root_object.attributes['TargetAttributes']
          proj.root_object.attributes['TargetAttributes'].store(target.uuid, target_config)
        elsif
          proj.root_object.attributes.store('TargetAttributes', { target.uuid => target_config })
        end

        target.build_configuration_list.set_setting('INFOPLIST_FILE', File.absolute_path("#{config_folder}/Info.plist"))
        target.build_configuration_list.set_setting('SWIFT_VERSION', '4.0')
        target.build_configuration_list.set_setting('PRODUCT_NAME', "$(TARGET_NAME)")
        target.build_configuration_list.set_setting('TEST_TARGET_NAME', project_name)
        target.build_configuration_list.set_setting('PRODUCT_BUNDLE_IDENTIFIER', "#{bundle_id}.#{scheme_name}")
        target.build_configuration_list.set_setting('CODE_SIGN_IDENTITY[sdk=iphoneos*]', "iPhone Developer")
        target.build_configuration_list.set_setting('LD_RUNPATH_SEARCH_PATHS', "$(inherited) @executable_path/Frameworks @loader_path/Frameworks")
        target.build_configuration_list.set_setting('DEVELOPMENT_TEAM', team_id)

        # Create a shared scheme for the UI tests
        existing_scheme = Xcodeproj::XCScheme.shared_data_dir(xcode_project_path) + "/#{scheme_name}.xcscheme"

        UI.message "Generating XCode Scheme #{scheme_name} to run UI Snapshot Tests"
        scheme = File.exist?(existing_scheme) ? Xcodeproj::XCScheme.new(existing_scheme) : Xcodeproj::XCScheme.new

        scheme.add_test_target(target)

        scheme.add_build_target(main_target)
        scheme.set_launch_target(main_target)

        scheme.save_as(xcode_project_path, scheme_name)

        UI.success "Completed Retrofit of #{scheme_name} in Ionic Generated XCode Project #{project_name} OK... SAVING"

        proj.save
      end

      def self.description
        'Bridge between Ionic/Cordova Projects and Fastlane for Automated Snapshot Generation for iOS Projects'
      end

      def self.authors
        ['Adrian Regan']
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        'This plugin allows the developer to specify UI Unit Tests and store them in the fastlane configuration. The plugin will copy over these unit tests to the generated Xcode (and hopefully Android) projects, create the required targets/schemes to run the snapshots and integrate into fastlane. It allows for greater automation of the build for ionic/cordova projects that wish to use fastlane'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :ionic_ios_xcode_path,
                                       env_name: 'IONIC_IOS_XCODE_PATH',
                                       description: 'Path to XCode Project Generated by Ionic',
                                       default_value: Fastlane::Helper::IonicIntegrationHelper.find_default_ios_xcode_workspace,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :ionic_min_target_ios,
                                       env_name: 'IONIC_MIN_TARGET_IOS',
                                       description: 'Minimal iOS Version to Target',
                                       default_value: IonicIntegration::DEFAULT_IOS_VERSION,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :team_id,
                                       env_name: 'IONIC_TEAM_ID_IOS',
                                       description: 'Team Id in iTunesConnect or Apple Developer',
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_id),
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :bundle_id,
                                       env_name: 'IONIC_BUNDLE_ID_IOS',
                                       description: 'The Bundle Id of the iOS App, eg: ie.littlevista.whateverapp',
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:package_name),
                                       optional: false)

        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Platforms.md
        #
        # [:ios, :mac, :android].include?(platform)
        [:ios].include?(platform)
      end
    end
  end
end
