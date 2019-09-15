# Pylint ruby wrapper that can be used inside this gem
class Pylint
   def initialize(pylint_path = nil)
       @pylint_path = pylint_path
   end

    # Run pylint with arguments
   def run(files, options = {})
    puts "CMD:"

    options = dict_to_string(default_options.merge(options))

    files = files.join(' ')
    cmd = "#{pylint_path} #{files} #{options}"
    puts cmd

    result = `#{cmd}`
    puts result

   end

    def default_pylint_path
      '/usr/local/bin/pylint'
    end

    def pylint_path
       @pylint_path || default_pylint_path
    end

    def installed?
      File.exist?(pylint_path)
    end

    def default_options
       {
       'output-format': 'json'
       }
    end

    def dict_to_string(options)
       options.map{|k,v| "--#{k}=#{v}"}.join(' ')
    end

end

pylint = Pylint.new
pylint.run(['/Users/grzegorz/Developer/danger-pylint/example/foo.py'], {'rcfile': '/Users/grzegorz/Developer/danger-pylint/example/.pylintrc'})