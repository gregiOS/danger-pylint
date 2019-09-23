require File.expand_path('spec_helper', __dir__)

module Danger
  describe Danger::DangerPylint do
    # ASSETS_DIR = File.expand_path('assets', __dir__)
    # BANDIT_EMPTY = "#{ASSETS_DIR}/bandit_empty.json".freeze
    # BANDIT_FILE = "#{ASSETS_DIR}/bandit.json".freeze

    it 'should be a plugin' do
      expect(Danger::DangerPylint.new(nil)).to be_a Danger::Plugin
    end

    #
    # You should test your custom attributes and methods here
    #
    describe 'with Dangerfile' do
      before do
        @dangerfile = testing_dangerfile
        @my_plugin = @dangerfile.pylint
      end
        it 'should be DangerPylint' do
          expect(@my_plugin).to be_a Danger::DangerPylint
        end
    end
  end
end
