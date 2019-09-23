
require 'find'
require 'yaml'
require 'shellwords'
require_relative '../ext/pylint/pylint'
require_relative 'models/Issue'

module Danger
  class DangerPylint < Plugin
    attr_accessor :binary_path

    # The path to pylint rcfile file
    attr_accessor :rcfile

    # Provides additional logging diagnostic information.
    attr_accessor :verbose

    # Whether to comment as markdown report or do an inline comment on the file.
    #
    # This will be set as default for all reporters used in this danger run.
    # It can still be overridden by setting the value when using #report.
    #
    # @return [Bool] Use inline comments.
    attr_accessor :inline
    # Whether to filter and report only for changes files.
    # If this is set to false, all issues are of a report are included in the comment.
    #
    # This will be set as default for all reporters used in this danger run.
    # It can still be overridden by setting the value when using #report.
    #
    # @return [Bool] Filter for changes files.
    attr_accessor :filter
    # Whether to fail the PR if any high issue is reported.
    #
    # This will be set as default for all reporters used in this danger run.
    # It can still be overridden by setting the value when using #report.
    #
    # @return [Bool] Fail on high issues.
    attr_accessor :fail_error

    ERROR_PYLINT_NOT_INSTALLED = 'PyLint not installed.'.freeze
    ERROR_HIGH_SEVERITY = '%s has high severity errors.'.freeze

    def lint
      validate
      run_pylint
      filter_issues
      comment
      fail_on_error
    end

    def validate
      raise ERROR_PYLINT_NOT_INSTALLED unless pylint.installed?
    end

    def run_pylint
      files = Dir["#{Dir.pwd}/**/*.py"]
      log("Running pylint for files: #{files}")
      result = pylint.run(files, @rcfile, options)
      @issues = JSON.parse(result).flatten.map { issue | Issue(issue) } unless !result
      log("Found following issuese #{@issues}")
    end

    def filter_issues
      return unless filter
      log("Filtering issues")
      git_files = git.modified_files + git.added_files
      @issues.select! do |issue|
        git_files.include?(issue.file_name)
      end
    end

    def comment
      return if @issues.empty?
      @inline ? inline_comment : markdown_issues
    end

    def inline_comment
      return unless @issues.empty?
      @issues.each do |issue|
        send(issue.severity, issue.message, file: issue.file_name, line: issue.line)
        end
    end

    def markdown_comment
      text = MessageUtil.markdown(@issues)
      markdown(text)
    end

    def fail_on_error
      fail(format(ERROR_HIGH_SEVERITY, name)) if @fail_error && high_issues?
    end

    def high_issues?
      result = false
      @issues.each do |issue|
        result = issue.severity.eql?(:high)
      end
      result
    end

    def pylint
      Pylint.new(binary_path)
    end

    def log(text)
      puts(text) unless !@verbose
    end
  end
end

# Issues found: [{"type"=>"fatal", "module"=>"danger-pylint", "obj"=>"", "line"=>1, "column"=>0, "path"=>"__init__.py",
# "symbol"=>"parse-error",
# "message"=>"error while code parsing: Unable to load file /Users/grzegorz/Developer/danger-pylint/__init__.py:\n[Errno 2]
# No such file or directory: '/Users/grzegorz/Developer/danger-pylint/__init__.py'",
# "message-id"=>"F0010"}]
#
#  {
#         "type": "warning",
#         "module": "foo",
#         "obj": "",
#         "line": 6,
#         "column": 0,
#         "path": "example/foo.py",
#         "symbol": "pointless-statement",
#         "message": "Statement seems to have no effect",
#         "message-id": "W0104"
#     },