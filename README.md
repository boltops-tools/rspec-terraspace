# rspec-terraspace

Terraspec rspec helper methods.

## Usage

Let's say you have terraform module named demo:

    demo
    ├── main.tf
    ├── outputs.tf
    └── variables.tf

Create a `demo/test` folder to add tests. Example:

test/spec/main_spec.rb:

```ruby
describe "main" do
  before(:all) do
    mod_path = File.expand_path("../..", __dir__)
    # Build terraspace project to use as a test harness
    # Will be located at: /tmp/terraspace/test-harnesses/network
    terraspace.build_test_harness(
      name: "network", # terraspace project name
      modules: {example: mod_path},
      stacks:  {example: "#{mod_path}/test/spec/fixtures/stack"},
    )
    terraspace.up("example") # example is the module or stack name under testing
  end
  after(:all) do
    terraspace.down("example") # example is the module or stack name under testing
  end

  it "successful deploy" do
    # example is the module or stack name under testing
    network_id = terraspace.output("example", "network_id")
    expect(network_id).to include("networks") # IE: projects/tung-275700/global/networks/ladybug
  end
end
```

### Run Tests

To run the spec:

    rspec

The test will:

1. Build a test harness. The test harness is a generated terraspace project with the specified modules and stacks.
2. Runs a `terraspace up` (`terraform apply`) to create real resources.
3. Check the resources. In this case, it simply checks for the terraform output.
4. Runs a `terraspace down` (`terraform destroy`) to clean up the real resources.

### Test harness location

Where is the generated test harness located?

The test hardness is materialized in `/tmp/terraspace/test-harnesses/NAME` by default. The build root can be controlled with `TS_RSPEC_BUILD_ROOT` env var.

So if you set it: `export TS_RSPEC_BUILD_ROOT=~/environment/terraspace-test-harnesses`. It will be build at `~/environment/terraspace-test-harnesses/NAME` instead.

## Example

A more complete example is in [docs/examples/demo](docs/examples/demo).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-terraspace'
```

And then execute:

    $ bundle install

