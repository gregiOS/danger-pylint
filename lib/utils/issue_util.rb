
module Danger
  module IssueUtil
    TABLE_HEADER = '|Severity|File|Validation-id|Message|'.freeze
    COLUMN_SEPARATOR = '|'.freeze
    TABLE_SEPARATOR = "#{COLUMN_SEPARATOR}---#{COLUMN_SEPARATOR}---#{COLUMN_SEPARATOR}---#{COLUMN_SEPARATOR}".freeze
    LINE_SEPARATOR = "\n".freeze

    module_function
    # Generate a markdown text message listing all issues as table.
    #
    # @param issues [Array<Issue>] List of parsed issues.
    # @return [String] String in danger markdown format.
    def markdown(issues)
      result = header_name
      result << header
      result << issues(issues)
    end

    def header_name
      "# pylint#{LINE_SEPARATOR}"
    end

    def header
      result = TABLE_HEADER.dup
      result << LINE_SEPARATOR
      result << TABLE_SEPARATOR
      result << LINE_SEPARATOR
    end

    def issues(issues)
      return '' unless issues
      result = ''
      issues.each do |issue|
        result << COLUMN_SEPARATOR.dup
        result << issue.severity.to_s.capitalize
        result << COLUMN_SEPARATOR
        result << "#{issue.file_name}:#{issue.line}"
        result << COLUMN_SEPARATOR
        result << "#{issue.message}"
        result << COLUMN_SEPARATOR
        result << LINE_SEPARATOR
      end
      # rubocop:enable Metrics/AbcSize
      result
    end
  end
end