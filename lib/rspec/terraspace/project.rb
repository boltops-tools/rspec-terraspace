require "fileutils"
require "tmpdir"

module RSpec::Terraspace
  class Project
    def initialize(options={})
      @options = options
      @name    = options[:name]
      @config  = options[:config]
      @modules = options[:modules]
      @stacks  = options[:stacks]
      @tfvars  = options[:tfvars]
      @folders = options[:folders]
      @plugin  = options[:plugin]

      @remove_test_folder = options[:remove_test_folder].nil? ? true : options[:remove_test_folder]
    end

    def create
      puts "Building test harness at: #{build_dir}"
      clean
      build_project
      build_config
      build_modules
      build_stacks
      build_tfvars
      build_folders
      puts "Test harness built."
      build_dir
    end

    # folders at any-level, including top-level can be copied with the folders option
    def build_folders
      return unless @folders

      @folders.each do |folder|
        dest = "#{build_dir}/#{folder}"
        FileUtils.mkdir_p(File.dirname(dest))
        FileUtils.cp_r(folder, dest)
      end
    end

    def build_project
      parent_dir = File.dirname(build_dir)
      FileUtils.mkdir_p(parent_dir)
      Dir.chdir(parent_dir) do
        project_name = File.basename(build_dir)
        args = [project_name, "--no-config", "--quiet"] + plugin_option
        ::Terraspace::CLI::New::Project.start(args)
      end
    end

    def plugin_option
      if @plugin
        ["-p", @plugin]
      else
        provider = autodetect_provider || "none"
        ["-p", provider]
      end
    end

    def autodetect_provider
      providers = Terraspace::Plugin.meta.keys
      if providers.size == 1
        providers.first
      else
        precedence = %w[aws azurerm google]
        precedence.find do |p|
          providers.include?(p)
        end
      end
    end

    def build_config
      return unless @config

      config_folder = "#{build_dir}/config"
      FileUtils.mkdir_p(File.dirname(config_folder))
      Dir.glob("#{@config}/*").each do |src|
        FileUtils.cp_r(src, config_folder)
      end
    end

    def build_modules
      return unless @modules
      build_type_folder("modules", @modules)
    end

    def build_stacks
      return unless @stacks
      build_type_folder("stacks", @stacks)
    end

    # If a file has been supplied, then it gets copied over.
    #
    #     # File
    #     terraspace.build_test_harness(
    #       tfvars: {demo: "spec/fixtures/tfvars/demo.tfvars"},
    #     end
    #
    #     # Results in:
    #     app/stacks/#{stack}/tfvars/test.tfvars
    #
    # If a directory has been supplied, then the folder fully gets copied over.
    #
    #     # Directory
    #     terraspace.build_test_harness(
    #       tfvars: {demo: "spec/fixtures/tfvars/demo"},
    #     end
    #
    #     # Results in (whatever is in the folder):
    #     app/stacks/#{stack}/tfvars/base.tfvars
    #     app/stacks/#{stack}/tfvars/test.tfvars
    #
    def build_tfvars
      return unless @tfvars
      @tfvars.each do |stack, src|
        type = detected_type
        tfvars_folder = "#{build_dir}/app/#{type}/#{stack}/tfvars"
        FileUtils.rm_rf(tfvars_folder) # wipe current tfvars folder. dont use any of the live values

        if File.directory?(src)
          FileUtils.mkdir_p(File.dirname(tfvars_folder))
          FileUtils.cp_r(src, tfvars_folder)
        else # if only a single file, then generate a test.tfvars since this runs under TS_ENV=test
          dest = "#{tfvars_folder}/test.tfvars"
          FileUtils.mkdir_p(File.dirname(dest))
          FileUtils.cp(src, dest)
        end
      end
    end

    # Returns: modules or stacks
    def detected_type
      dir = Dir.pwd
      md = dir.match(%r{app/(stacks|modules)/(.*)?/?})
      md[1]
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
    def build_type_folder(type_dir, list)
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
      "#{tmp_root}/#{@name}"
    end

    def tmp_root
      self.class.tmp_root
    end

    def self.tmp_root
      "#{Terraspace.tmp_root}/test-harnesses"
    end
  end
end
