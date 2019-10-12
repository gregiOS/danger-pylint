require File.expand_path('spec_helper', __dir__)

module Danger
  describe Danger::DangerPylint do

    ASSETS_DIR = File.expand_path('assets', __dir__)
    REPORT_FILE = "#{ASSETS_DIR}/report.json".freeze
    ISSUES_STRING = File.read(REPORT_FILE).freeze
    it 'should be a plugin' do
      expect(Danger::DangerPylint.new(nil)).to be_a Danger::Plugin
    end

    #
    # You should test your custom attributes and methods here
    #
    describe 'with Dangerfile' do
      before do
        @dangerfile = testing_dangerfile
        @pylint = @dangerfile.pylint
      end
      it 'should be DangerPylint' do
        expect(@pylint).to be_a Danger::DangerPylint
      end

      it 'should raise error when Pylint not installed' do
        expect(@pylint.pylint).to receive(:installed?).once.and_return(false)
        expect { @pylint.lint }.to raise_error(DangerPylint::ERROR_PYLINT_NOT_INSTALLED)
      end

      describe :lint_files do
        before do
          allow_any_instance_of(Pylint).to receive(:installed?).and_return(true)
          allow(@pylint.git).to receive(:added_files).and_return([])
          allow(@pylint.git).to receive(:modified_files).and_return([])

        end

        it 'should lint all found files' do
          expect(Dir).to receive(:glob).and_return(['bar.py'])

          expect_any_instance_of(Pylint).to receive(:run).with(['bar.py'], nil)
          @pylint.lint
        end

        it 'should run pylint and return json result' do
          allow(@pylint.git).to receive(:added_files).and_return(["bar.py"])

          @pylint.lint
        end

        context "inline" do

          it 'filters lint issues to return issues in added files' do
            allow(@pylint.git).to receive(:added_files).and_return(["example/foo.py"])
            expect(@pylint.pylint).to receive(:run).and_return(ISSUES_STRING)

            @pylint.lint

            status = @pylint.status_report
            expect(status[:warnings]).to eql(["Warning|W0311|Bad indentation. Found 2 spaces, expected 4", "Warning|W0311|Bad indentation. Found 3 spaces, expected 8"])
            expect(status[:errors]).to eql(["Convention|C0304|Final newline missing"])
            expect(status[:messages]).to be_empty
          end

          it 'filter lint issue and return issue in modified files' do
            allow(@pylint.git).to receive(:modified_files).and_return(["example/foo.py"])
            expect(@pylint.pylint).to receive(:run).and_return(ISSUES_STRING)

            @pylint.lint

            status = @pylint.status_report

            print(status)
            expect(status[:warnings]).to eql(["Warning|W0311|Bad indentation. Found 2 spaces, expected 4", "Warning|W0311|Bad indentation. Found 3 spaces, expected 8"])
            expect(status[:errors]).to eql(["Convention|C0304|Final newline missing"])
            expect(status[:messages]).to be_empty
          end

          it 'filter lint issue and return no issues' do
            allow(@pylint.git).to receive(:modified_files).and_return([])
            allow(@pylint.git).to receive(:added_files).and_return([])
            expect(@pylint.pylint).to receive(:run).and_return(ISSUES_STRING)

            @pylint.lint

            status = @pylint.status_report
            expect(status[:warnings]).to be_empty
            expect(status[:errors]).to be_empty
            expect(status[:messages]).to be_empty
          end

        end

        context "markdown" do

          before do
            @pylint.inline = false
            @pylint.filter = false
          end

          it "Should return comments in markdown" do
            expect(@pylint.pylint).to receive(:run).and_return(ISSUES_STRING)

            @pylint.lint

            status = @pylint.status_report

            expect(status[:warnings]).to be_empty
            expect(status[:errors]).to be_empty
            expect(status[:messages]).to be_empty
            expect(status[:markdowns].count).to eql(1)
            expect(status[:markdowns][0].message).to eql("# pylint\n|Severity|File|Validation-id|Message|\n|---|---|---|\n|Warn|foo.py:2|Warning|W0311|Bad indentation. Found 2 spaces, expected 4|\n|Warn|foo.py:3|Warning|W0311|Bad indentation. Found 3 spaces, expected 8|\n|Fail|foo.py:8|Convention|C0304|Final newline missing|\n")
          end

        end
      end

    end
  end
end
