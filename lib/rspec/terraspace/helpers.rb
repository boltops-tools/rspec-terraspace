module RSpec::Terraspace
  module Helpers
    extend Memoist

    def reconfigure_logging(level="info")
      path = "/tmp/terraspace/log/test.log"
      FileUtils.mkdir_p(File.dirname(path))
      Terraspace.logger = Terraspace::Logger.new(path)
      puts "Terraspace.logger has been reconfigured to #{path}"
    end

    def ts
      Ts.new
    end
    memoize :ts
    alias_method :terraspace, :ts
  end
end
