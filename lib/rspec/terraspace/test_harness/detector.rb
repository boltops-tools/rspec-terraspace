class RSpec::Terraspace::TestHarness
  class Detector
    extend Memoist

    # IE: demo
    def mod_name
      mod_path.split('/')[2..-1].join('/')
    end

    # IE: app/stacks/demo
    # IE: app/modules/example
    def mod_path
      mod_full_path.sub("#{original_root}/", '')
    end

    # IE: /home/user/terraspace-project/app/stacks/demo
    def mod_full_path
      calling_file.sub(%r{/test/spec/.*}, '')
    end

    # IE: /home/user/terraspace-project
    def original_root
      calling_file.sub(%r{/(app|vendor)/(stacks|modules)/.*}, '')
    end

    # Automatically discover the stack root path
    #
    # Caller lines are different for OSes:
    #
    #   windows: "C:/Users/user/terraspace-project/app/stacks/demo/test/spec/stack_spec.rb:12:in `block (2 levels) in <top (required)>'"
    #   linux: "/home/user/terraspace-project/app/stacks/demo/test/spec/stack_spec.rb:12:in `block (2 levels) in <top (required)>'"
    #
    def calling_file
      caller_line = caller.find { |l| l.include?("_spec.rb") }
      parts = caller_line.split(':')
      caller_line.match(/^[a-zA-Z]:/) ? parts[1] : parts[0]
    end
    memoize :calling_file
  end
end
