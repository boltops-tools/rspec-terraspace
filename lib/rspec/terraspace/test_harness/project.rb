
require "fileutils"
require "tmpdir"
require "terraspace-bundler"

class RSpec::Terraspace::TestHarness
  class Project
    extend Memoist

    def initialize(options={})
      @options = options
      @test_type  = options[:test_type] || "module" # module or stack
      @config     = options[:config] || "spec/fixtures/config"

      # @modules    = options[:modules] # default nil builds all modules
      # @tfvars     = options[:tfvars] || "spec/fixtures/tfvars"
      # @folders    = options[:folders]
      # @plugin     = options[:plugin] # by default will auto-detect

      # @root       = options[:root] || detection.root # IE: /home/user/terraspace-project/app/stacks/demo
      # @remove_test_folder = options[:remove_test_folder].nil? ? true : options[:remove_test_folder]
    end

    def build_example_as_stack
      # app/modules/pet/examples/pet1
      src = "#{detection.original_root}/#{detection.mod_path}/examples/#{example_name}"
      dest = "#{harness_root}/app/stacks/#{example_name}"
      FileUtils.cp_r(src, dest)
      # Use terraspace-bundler class to rewrite source = ... line
      rewrite = TerraspaceBundler::Exporter::Stacks::Rewrite.new(
        folder: dest, # IE: /tmp/terraspace/test_harness/pet
        mod_name: detection.mod_name, # IE: pet (from app/modules/pet)
      )
      rewrite.run
    end

    def example_name
      @options[:example] # || detect_first_example
    end

    # Auto-detection Feature
    #
    #   test_harness.mod_name      # demo
    #   test_harness.mod_path      # app/modules/pet
    #   test_harness.original_root # original Terraspace.root full_path
    #
    def detection
      Detector.new
    end
    memoize :detection

    def create
      # if @test_type == "stack"
      #   create_stack_project
      # else
        create_module_project
      # end
    end

    def create_module_project
      puts "Building test harness at: #{harness_root}"
      clean
      build_project
      build_config
      build_module
      build_example_as_stack
      # build_tfvars
      # build_folders
      puts "Test harness built."
      harness_root
    end

    def build_module
      src = "#{detection.original_root}/#{detection.mod_path}"
      dest = "#{harness_root}/#{detection.mod_path}"
      FileUtils.cp_r(src, dest)
    end

    # folders at any-level, including top-level can be copied with the folders option
    def build_folders
      return unless @folders

      @folders.each do |folder|
        dest = "#{harness_root}/#{folder}"
        FileUtils.mkdir_p(File.dirname(dest))
        FileUtils.cp_r(folder, dest)
      end
    end

    def build_project
      parent_dir = File.dirname(harness_root)
      FileUtils.mkdir_p(parent_dir)
      Dir.chdir(parent_dir) do
        project_name = File.basename(harness_root)
        args = [project_name, "--quiet"]
        options = @options[:new_project_options]
        options = options ? [options.split(' ')].flatten.compact : []
        args += options
        Terraspace::CLI::New::Project.start(args)
      end
    end

    def build_config
      return unless File.exist?(@config)
      config_folder = "#{harness_root}/config"
      FileUtils.mkdir_p(File.dirname(config_folder))
      Dir.glob("#{@config}/*").each do |src|
        FileUtils.cp_r(src, config_folder)
      end
    end

    def build_stacks
      build_type_folder("stacks", @modules)
    end

    def build_modules
      build_type_folder("modules", @modules)
    end

    # Inputs:
    #
    #     type_dir: modules or stacks
    #     object:   Hash or String
    #
    # The object argument can support a Hash or String value.
    #
    # If provided a Hash, it should be structured like so:
    #
    #    {vm: "app/stacks/vm", network: "app/stacks/network"}
    #
    # This allows for finer-control to specify what stacks and stacks to build
    #
    # If provide a String, it should be a path to folder containing all stacks or stacks.
    # This provides less fine-grain control but is easier and shorter to use.
    #
    def build_type_folder(type_dir, object)
      case object
      when Hash
        object.each do |name, src|
          dest = "#{harness_root}/app/#{type_dir}/#{name}"
          copy(src, dest)
          remove_test_folder(dest) if @remove_test_folder
        end
      when String
        dest = "#{harness_root}/app/#{type_dir}"
        FileUtils.rm_rf(dest)
        FileUtils.cp_r(object, dest)
      when NilClass
        puts "Copying all modules from #{Terrapsace.root}"
        puts "...."
      else
        raise "stacks option must be a Hash or String"
      end
    end

    # If a file has been supplied, then it gets copied over.
    #
    #     # File
    #     Terraspace.test_harness.build(
    #       tfvars: "spec/fixtures/tfvars/demo.tfvars",
    #     end
    #
    #     # Results in:
    #     app/stacks/#{detection.mod_name}/tfvars/test.tfvars
    #
    # If a directory has been supplied, then the folder fully gets copied over.
    #
    #     # Directory
    #     Terraspace.test_harness.build(
    #       tfvars: {demo: "spec/fixtures/tfvars/demo"},
    #     end
    #
    #     # Results in (whatever is in the folder):
    #     app/stacks/#{detection.mod_name}/tfvars/base.tfvars
    #     app/stacks/#{detection.mod_name}/tfvars/test.tfvars
    #
    def build_tfvars
      @tfvars.each do |src|
        folder = "#{harness_root}/config/stacks/#{detection.mod_name}/tfvars"
        FileUtils.rm_rf(folder) # wipe current tfvars folder

        if File.directory?(src)
          FileUtils.mkdir_p(File.dirname(folder))
          FileUtils.cp_r(src, folder)
        elsif File.exist?(src) # if only a single file, then generate a test.tfvars since this runs under Terraspace_ENV=test
          dest = "#{folder}/#{Terraspace.env}.tfvars"
          FileUtils.mkdir_p(File.dirname(dest))
          FileUtils.cp(src, dest)
        end
      end
    end

    def remove_test_folder(dest)
      FileUtils.rm_rf("#{dest}/test")
    end

    def clean
      FileUtils.rm_rf(harness_root)
    end

    def copy(src, dest)
      FileUtils.mkdir_p(File.dirname(dest))
      FileUtils.cp_r(src, dest)
    end

    # test_harness.harness_root  # /tmp/terraspace/test-harnesses/pet
    def harness_root
      "#{tmp_root}/#{detection.mod_name}"
    end

    def tmp_root
      self.class.tmp_root
    end

    def self.tmp_root
      "#{Terraspace.tmp_root}/test-harnesses"
    end
  end
end
