require "json"

module RSpec::Terraspace
  class Ts
    extend Memoist
    include Concern

    CLI = ::Terraspace::CLI

    def build_test_harness(options={})
      setup
      project = Project.new(options)
      root = project.create
      Terraspace.root = root # switch root to the generated test harness
    end

    def setup
      # Require gems in Gemfile so terraspace_plugin_* gets loaded and registered
      # This it test Gemfile. IE: app/stacks/demo/test/Gemfile
      Kernel.require "bundler/setup"
      Bundler.require # Same as Bundler.require(:default)
      Terraspace.check_project = false
    end

    def up(args)
      Terraspace::Logger.clear
      run("up #{args} -y")
      mod = args.split(' ').first
      @mod = ::Terraspace::Mod.new(mod)
    end

    def down(args)
      Terraspace::Logger.clear
      run("down #{args} -y")
    end

    def run(command)
      puts "=> TS_ENV=#{Terraspace.env} terraspace #{command}".color(:green)
      args = command.split(' ')
      CLI.start(args)
    end
  end
end
