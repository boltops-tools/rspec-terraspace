ENV["TS_ENV"] = "test"

require "terraspace"
require "rspec/terraspace"

module Helper
  def execute(cmd)
    puts "Running: #{cmd}" if show_command?
    out = `#{cmd}`
    puts out if show_command?
    out
  end
end

RSpec.configure do |c|
  c.include Helper
  c.include RSpec::Terraspace::Helpers
end
