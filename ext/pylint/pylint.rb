# Pylint ruby wrapper that can be used inside this gem
class Pylint
   def initialize(pylint_path = nil, verbose = false)
     @pylint_path = pylint_path
     @verbose = verbose
   end

    # Run pylint with arguments
   def run(files = [], rcfile = nil, options = {})

    options = dict_to_string(default_options(rcfile).merge(options))

    files = files.empty? ? "" : files.join(' ')
    cmd = "#{pylint_path} #{files} #{options}"

    puts "#{cmd}" unless !@verbose

    `#{cmd}`
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

    def default_options(rcfile = nil)
       if rcfile.nil?
         {
             'output-format': 'json'
         }
       else
         rcfile = File.join(Dir.pwd, rcfile) unless (rcfile.include? Dir.pwd)
         {
             'output-format': 'json',
             'rcfile': "#{rcfile}"
         }
       end
    end

    def dict_to_string(options)
       options.map{|k,v| "--#{k}=#{v}"}.join(' ')
    end

end