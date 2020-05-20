module RSpec::Terraspace
  class Ts
    def build_test_harness(options={})
      puts "build_test_harness"
      project = Project.new(options)
      project.create
    end

    def up
      puts "up"
    end

    def down
      puts "down"
    end
  end
end
