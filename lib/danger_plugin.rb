
require 'find'
require 'yaml'
require 'shellwords'
require_relative '../ext/pylint/pylint'
require_relative 'models/issue'
require_relative 'utils/issue_util'

# include Issue

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
    attr_accessor :fail_on_error

    ERROR_PYLINT_NOT_INSTALLED = 'PyLint not installed.'.freeze
    ERROR_HIGH_SEVERITY = '%s has high severity errors.'.freeze
    DEFAULT_FILTER = true
    DEFAULT_INLINE = true
    def initialize(dangerfile)
      super(dangerfile)
      self.inline ||= DEFAULT_INLINE
      self.filter ||= DEFAULT_FILTER
    end
    def lint
      validate
      run_pylint
      filter_issues
      comment
      fail_if_error
    end

    def validate
      raise ERROR_PYLINT_NOT_INSTALLED unless pylint.installed?
    end

    def run_pylint
      files = Dir.glob("#{Dir.pwd}/**/*.py")
      log("Running pylint for files: #{files}")
      result = pylint.run(files, @rcfile)
      if result
        @issues = JSON.parse(result).flatten.map { |issue| Danger::Issue.new(issue) }
      else
        @issues = []
      end
      log("Found following issues #{@issues}")
    end

    def filter_issues
      return unless filter
      log("Filtering issues")
      git_files = git.modified_files + git.added_files
      print(git_files)
      @issues.select! do |issue|
        git_files.include?(issue.path)
      end
      log("Issues found after filtering: #{@issues}")
    end

    def comment
      inline ? inline_comment : markdown_issues
    end

    def inline_comment
      log("Create inline comments")
      @issues.each do |issue|
        send(issue.severity, issue.message, file: issue.file_name, line: issue.line)
      end
    end

    def markdown_issues
      log("Create markdown report")
      text = IssueUtil.markdown(@issues)
      markdown(text)
    end

    def fail_if_error
      fail(format(ERROR_HIGH_SEVERITY, name)) if fail_on_error && high_issues?
    end

    def high_issues?
      result = false
      @issues.each do |issue|
        result = issue.severity.eql?(:high)
      end
      result
    end

    def pylint
      @pylint ||= Pylint.new(binary_path)
    end

    def log(text)
      if :verbose
        puts(text)
        puts
      end
    end
  end
end
