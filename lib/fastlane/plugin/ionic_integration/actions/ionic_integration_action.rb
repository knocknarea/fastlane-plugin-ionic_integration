module Fastlane
  module Actions
    class IonicIntegrationAction < Action
      def self.run(params)
        UI.message("The ionic_integration plugin is working!")
      end

      def self.description
        "Integrating Fastlane with Ionic Generated Projects"
      end

      def self.authors
        ["Adrian Regan"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Fastlane assumes that you are in control of the XCode/Android Projects. Ionic/Cordova generates the build projects. This plugin enables addition of UI Unit Testing forr snapshot generation, retrofitting the Ionic/Cordova generated project appropriately. It opens the door to automated building and publishing of Ionic code using fastlane"
      end

      def self.available_options
        [
          # FastlaneCore::ConfigItem.new(key: :your_option,
          #                         env_name: "IONIC_INTEGRATION_YOUR_OPTION",
          #                      description: "A description of your option",
          #                         optional: false,
          #                             type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Platforms.md
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
