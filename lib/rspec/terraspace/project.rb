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
      build_app_subfolder(@modules, "modules")
    end

    def build_stacks
      build_app_subfolder(@stacks, "stacks")
    end

    # Inputs:
    #
    #     list:     options[:modules] or options[:stacks]
    #     type_dir: modules or stacks
    #
    # The list argument can support a Hash or String value.
    #
    # If provided a Hahs, it should be structured like so:
    #
    #    {vm: "app/modules/vm", network: "app/modules/network"}
    #
    # This allows for finer-control to specify what modules and stacks to build
    #
    # If provide a String, it should be a path to folder containing all modules or stacks.
    # This provides less fine-grain control but is easier to use and shorter.
    #
    def build_app_subfolder(list, type_dir)
      case list
      when Hash
        list.each do |name, src|
          dest = "#{build_dir}/app/#{type_dir}/#{name}"
          copy(src, dest)
          remove_test_folder(dest) if @remove_test_folder
        end
      when String
        dest = "#{build_dir}/app/#{type_dir}"
        FileUtils.rm_rf(dest)
        FileUtils.cp_r(list, dest)
      else
        raise "modules option must be a Hash or String"
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
