require "fileutils"
require "tmpdir"

module RSpec::Terraspace
  class Project
    def initialize(options={})
      @options = options
      @name    = options[:name] || "demo"
      @modules = options[:modules]
      @stacks  = options[:stacks]
    end

    def create
      clean

      parent_dir = File.dirname(build_dir)
      FileUtils.mkdir_p(parent_dir)
      Dir.chdir(parent_dir) do
        project_name = File.basename(build_dir)
        ::Terraspace::CLI::New::Project.start([project_name])
      end

      # TODO: terraspace new project --no-config option instead
      FileUtils.rm_f("#{build_dir}/config/backend.tf")
      FileUtils.rm_f("#{build_dir}/config/provider.tf")

      @modules.each do |name, src|
        dest = "#{build_dir}/app/modules/#{name}"
        copy(src, dest)
        remove_test_folder(dest)
      end
      @stacks.each do |name, src|
        dest = "#{build_dir}/app/stacks/#{name}"
        copy(src, dest)
      end

      puts "Test harness built: #{build_dir}"
      build_dir
    end

    def remove_test_folder(dest)
      FileUtils.rm_rf("#{dest}/test")
    end

    def clean
      FileUtils.rm_rf(build_dir)
    end

    def copy(src, dest)
      FileUtils.mkdir_p(File.dirname(dest))
      FileUtils.cp_r(src, dest)
    end

    def build_dir
      "#{build_root}/#{@name}"
    end

    def build_root
      # TODO: move to /tmp/terraspace/test-harnesses
      ENV['TS_RSPEC_BUILD_ROOT'] || "#{ENV['HOME']}/environment/terraspace-test-harnesses"
    end
  end
end
