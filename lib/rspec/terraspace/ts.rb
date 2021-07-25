require "json"

module RSpec::Terraspace
  class Ts
    extend Memoist

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
      save_output
    end

    def down(args)
      run("down #{args} -y")
    end

    def run(command)
      ENV['TS_ENV'] = Terraspace.env
      puts "=> TS_ENV=#{Terraspace.env} terraspace #{command}".color(:green)
      puts "command #{command}"
      args = command.split(' ')
      puts "args2 #{args}"
      CLI.start(args)
    end

    # Note: a terraspace.down will remove the output.json since it does a clean
    def save_output
      FileUtils.mkdir_p(File.dirname(out_path))
      run("output #{@mod.name} --format json --out #{out_path}")
    end

    def output(mod, name)
      outputs.dig(name, "value")
    end

    def outputs
      JSON.load(IO.read(out_path))
    end

    def out_path
      "#{Terraspace.tmp_root}/rspec/output.json"
    end
  end
end
