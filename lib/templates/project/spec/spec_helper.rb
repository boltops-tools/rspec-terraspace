ENV["TS_ENV"] = "test"

require "terraspace"
require "rspec/terraspace"

module Helper
  def execute(cmd)
    puts "Running: #{cmd}" if ENV['SHOW_COMMAND']
    out = `#{cmd}`
    puts out if ENV['SHOW_COMMAND']
    out
  end
end

RSpec.configure do |c|
  c.before(:all) do
    Dir.glob("config/helpers/**/*.rb").each do |path|
      require "./#{path}"
      name = path.sub(%r{config/helpers/},'').sub('.rb','').camelize
      mod = "Terraspace::Project::#{name}"
      c.include mod.constantize
    end
  end
end
