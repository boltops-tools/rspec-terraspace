module RSpec::Terraspace
  module Concern
    extend Memoist

    def output(mod, name)
      outputs.dig(name, "value")
    end

    def outputs
      save_output
      JSON.load(IO.read(out_path))
    end

    # Note: a terraspace.down will remove the output.json since it does a clean
    def save_output
      FileUtils.mkdir_p(File.dirname(out_path))
      run("output #{@mod.name} --format json --out #{out_path}")
    end
    memoize :save_output

    def out_path
      "#{Terraspace.tmp_root}/rspec/terraform-output.json"
    end

    def state
      save_state
      JSON.load(IO.read(state_path))
    end

    # full_name: random_pet.this
    def state_resource(full_name)
      type, name = full_name.split('.')
      state['resources'].find do |i|
        i['type'] == type && i['name'] == name || # IE: type=random_pet name=this
        i['module'] == full_name # IE: module.bucket
      end
    end

    def save_state
      FileUtils.mkdir_p(File.dirname(state_path))
      run("state pull #{@mod.name} --out #{state_path}")
    end
    memoize :save_state

    def state_path
      "#{Terraspace.tmp_root}/rspec/terraform-state.json"
    end

  end
end
