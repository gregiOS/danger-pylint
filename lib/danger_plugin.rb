
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

    def lint_files(files = nil, inline_mode: false, fail_on_error: false, no_comment: false, &select_block)
      files_array =
        if files.nil?
          [Dir.pwd]
        else
          files_array = files
        end

      options =
          if rcfile.nil?
            {}
          else
            {
                'rcfile': "#{@rcfile}"
            }
          end

      issues = run_pylint(files, options)

      log "Issues found: #{issues}"
    end

    # Run pylint on all files and returns the issues
    #
    # @return [Array] pylint issues
    def run_pylint(files, options = nil)
      result = pylint.run(files, options)
      if result == ''
        {}
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

  end
end
