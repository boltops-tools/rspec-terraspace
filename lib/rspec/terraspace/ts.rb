require "json"

module RSpec::Terraspace
  class Ts
    extend Memoist
    include Concern

    CLI = ::Terraspace::CLI

    def build_test_harness(options={})
      project = Project.new(options)
      root = project.create
      Terraspace.root = root # switch root to the generated test harness
    end

    def up(args)
      run("up #{args} -y")
      mod = args.split(' ').first
      @mod = ::Terraspace::Mod.new(mod)
    end

    def down(args)
      run("down #{args} -y")
    end

    def run(command)
      puts "=> TS_ENV=#{Terraspace.env} terraspace #{command}".color(:green)
      args = command.split(' ')
      CLI.start(args)
    end
  end
end
