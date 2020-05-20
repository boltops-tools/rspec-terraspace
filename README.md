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
    terraspace.build_test_harness(
      name: "network",
      modules: {example: mod_path},
      stacks:  {example: "#{mod_path}/test/spec/fixtures/stack"},
    )
    terraspace.up("example")
  end
  after(:all) do
    terraspace.down("example")
  end

  it "successful deploy" do
    network_id = terraspace.output("example", "network_id")
    expect(network_id).to include("networks") # IE: projects/tung-275700/global/networks/ladybug
  end
end
```

To run the spec:

    rspec

The test will:

1. Build a test harness. The test harness is a generated terraspace project with the specified modules and stacks. They materialize in `/tmp/terraspace/test-harnesses/NAME`. The build root can be controlled with `TS_RSPEC_BUILD_ROOT` env var.
2. Runs a `terraspace up` (`terraform apply`) to create real resources.
3. Check the resources. In this case, it simply checks for the terraform output.
4. Runs a `terraspace down` (`terraform destroy`) to clean up the real resources.

Example in [docs/examples/demo](docs/examples/demo).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-terraspace'
```

And then execute:

    $ bundle install

