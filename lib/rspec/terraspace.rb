require "rspec/terraspace/version"

require "active_support/core_ext/class"
require "active_support/core_ext/hash"
require "active_support/core_ext/string"
require "memoist"
require "rainbow/ext/string"

require "rspec/terraspace/autoloader"
RSpec::Terraspace::Autoloader.setup

module Rspec
  module Terraspace
    class Error < StandardError; end
  end
end

require "terraspace"

Terraspace::Tester.register("rspec",
  root: File.expand_path("../..", __dir__)
)
