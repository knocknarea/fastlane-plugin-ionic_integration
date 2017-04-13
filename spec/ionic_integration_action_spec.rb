describe Fastlane::Actions::IonicIntegrationAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The ionic_integration plugin is working!")

      Fastlane::Actions::IonicIntegrationAction.run(nil)
    end
  end
end
