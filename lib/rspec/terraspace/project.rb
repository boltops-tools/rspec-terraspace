require "fileutils"
require "tmpdir"

module RSpec::Terraspace
  class Project
    def initialize(options={})
      @options = options
      @name    = options[:name] || "demo"
      @modules = options[:modules]
      @stacks  = options[:stacks]

      @remove_test_folder = options[:remove_test_folder].nil? ? true : options[:remove_test_folder]
    end

    def create
      clean
      build_project
      build_modules
      build_stacks
      puts "Test harness built: #{build_dir}"
      build_dir
    end

    def build_project
      parent_dir = File.dirname(build_dir)
      FileUtils.mkdir_p(parent_dir)
      Dir.chdir(parent_dir) do
        project_name = File.basename(build_dir)
        ::Terraspace::CLI::New::Project.start([project_name])
      end

      # TODO: terraspace new project --no-config option instead
      FileUtils.rm_f("#{build_dir}/config/backend.tf")
      FileUtils.rm_f("#{build_dir}/config/provider.tf")
    end

    def build_modules
      @modules.each do |name, src|
        dest = "#{build_dir}/app/modules/#{name}"
        copy(src, dest)
        remove_test_folder(dest) if @remove_test_folder
      end
    end

    def build_stacks
      @stacks.each do |name, src|
        dest = "#{build_dir}/app/stacks/#{name}"
        copy(src, dest)
      end
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
      ENV['TS_RSPEC_BUILD_ROOT'] || "/tmp/terraspace/test-harnesses"
    end
  end
end
