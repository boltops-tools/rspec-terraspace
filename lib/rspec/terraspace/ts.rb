require "json"

module RSpec::Terraspace
  class Ts
    extend Memoist

    CLI = ::Terraspace::CLI

    def build_test_harness(options={})
      puts "build_test_harness"
      project = Project.new(options)
      @ts_root = project.create
      ENV['TS_ROOT'] = @ts_root # switch root to the generated test harness
    end

    def up(args)
      run("up #{args} -y")
    end

    def down(args)
      run("down #{args} -y")
    end

    def run(command)
      args = command.split(' ')
      CLI.start(args)
    end

    def save_output(mod)
      run("output #{mod} --json --save-to #{saved_output_path}")
    end
    memoize :save_output

    def output(mod, name)
      save_output(mod)
      data = JSON.load(IO.read(saved_output_path))
      data.dig(name, "value")
    end

    def saved_output_path
      "#{@ts_root}/output.json"
    end
  end
end
