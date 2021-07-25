module RSpec::Terraspace
  class Logging
    def initialize(options={})
      @options = case options
                 when Hash, NilClass
                   options || {}
                 else # IO object
                   {type: options}
                 end
    end

    def reconfigure!
      type = @options[:type]
      case type
      when :file
        path = @options[:path] || "/tmp/terraspace/log/test.log"
        FileUtils.mkdir_p(File.dirname(path))
        Terraspace.logger = Terraspace::Logger.new(path)
        Terraspace.logger.level = @options[:level] || :info
        puts "Terraspace.logger has been reconfigured to #{path}"
      else # stderr
        Terraspace.logger = Terraspace::Logger.new(type)
      end
    end
  end
end
