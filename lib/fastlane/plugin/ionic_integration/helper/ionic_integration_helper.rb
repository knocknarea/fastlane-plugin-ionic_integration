module Fastlane
  module Helper
    class IonicIntegrationHelper
      # class methods that you define here become available in your action
      # as `Helper::IonicIntegrationHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the ionic_integration plugin helper!")
      end
    end
  end
end
