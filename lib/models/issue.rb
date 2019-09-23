module Danger
  class Issue
    def initialize(issue)
      @issue = issue
    end

    def message
      "#{@issue['type'].to_s.capitalize}|#{@issue['message-id']}|#{@issue['message']}"
    end

    def file_name
      @issue['path'].split('/').last
    end

    def fatal?
      @issue['type'] == 'Error' or @issue['type'] == 'fatal'
    end

    def severity
      @issue['type'] == "warning" ? :warn : :fail
    end

    def line
      @issue['line']
    end

  end
end