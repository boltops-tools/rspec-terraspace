describe "main" do
  before(:all) do
    mod_path = File.expand_path("../..", __dir__) # the source of the module under testing is 2 levels up
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
    expect(network_id).to include("networks") # IE: projects/tung-xxx/global/networks/ladybug
  end
end
