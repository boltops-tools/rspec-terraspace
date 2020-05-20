module RSpec::Terraspace
  module Helpers
    extend Memoist

    def ts
      Ts.new
    end
    memoize :ts
    alias_method :terraspace, :ts

    # def terraspace(command)
    #   args = command.split(' ')
    #   ::Terraspace::CLI.start(args)
    # end

    # def create_terraspace_project(options={})
    #   Project.new(options).create
    # end
  end
end
