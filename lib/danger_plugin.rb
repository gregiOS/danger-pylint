
require 'find'
require 'yaml'
require 'shellwords'
require_relative '../ext/pylint/pylint'

module Danger
  class DangerPylint < Plugin
    attr_accessor :binary_path

    # The path to pylint rcfile file
    attr_accessor :rcfile

    # Provides additional logging diagnostic information.
    attr_accessor :verbose

    # Whether all files should be linted in one pass
    attr_accessor :lint_all_files

    # Whether we should fail on warnings
    attr_accessor :strict

    # Warnings found
    attr_accessor :warnings

    # Errors found
    attr_accessor :errors

    # All issues found
    attr_accessor :issues

    # Whether all issues or ones in PR Diff to be reported
    attr_accessor :filter_issues_in_diff

    def lint_files(inline_mode: false, fail_on_error: false, no_comment: false, &select_block)

      options =
          if rcfile.nil?
            {}
          else
            @rcfile = File.join(Dir.pwd, @rcfile) unless (@rcfile.include? Dir.pwd)
            {
                'rcfile': "#{rcfile}"
            }
          end


      files = Dir["#{Dir.pwd}/**/*.py"]

      issues = run_pylint(files, options)

      @warnings = issues.select { |issue| issue['type'] == 'fatal' }
      @errors = issues.select { |issue| issue['type'] == 'warning' }

      if inline_mode
        send_inline_comment(issues)
      elsif warnings.count > 0 || errors.count > 0
        message = "### Pylint found issues\n\n".dup
        message << markdown_issues(warnings, 'Warnings') unless warnings.empty?
        message << markdown_issues(errors, 'Errors') unless errors.empty?

        puts message

      end

      log "Issues found: #{issues}"
    end

    # Run pylint on all files and returns the issues
    #
    # @return [Array] pylint issues
    def run_pylint(files, options = nil)
      result = pylint.run(files, options)
      puts result
      if result == ''
        []
      else
        JSON.parse(result).flatten
      end
    end

    # Make pylint object for binary_path
    #
    # @return [Pylint]
    def pylint
      Pylint.new(binary_path)
    end

    def log(text)
      puts(text) if @verbose
    end

    def send_inline_comment(results)
      dir = "#{Dir.pwd}/"
      results.each do |r|
        github_filename = r['path'].gsub(dir, '')
        message = "#{r['message']}".dup
        method = r['type'] == "warning" ? :warn : :fail
        # extended content here
        filename = r['path'].split('/').last
        message << "\n"
        message << "`#{r['symbol']}`" # helps writing exceptions // swiftlint:disable:this rule_id
        message << " `#{filename}:#{r['line']}`"

        send(method, message, file: github_filename, line: r['line'])
      end
    end

    def markdown_issues(results, heading)
      message = "#### #{heading}\n\n".dup

      message << "File | Line | Reason |\n"
      message << "| --- | ----- | ----- |\n"

      results.each do |r|
        filename = r['path'].split('/').last
        line = r['line']
        reason = r['message']
        rule = r['symbol']
        # Other available properties can be found int SwiftLint/…/JSONReporter.swift
        message << "#{filename} | #{line} | #{reason} (#{rule})\n"
      end

      message
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