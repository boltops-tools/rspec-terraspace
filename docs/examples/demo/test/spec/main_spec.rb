describe "main" do
  before(:all) do
    mod_path = File.expand_path("../..", __dir__)
    terraspace.build_test_harness(
      name: "vm",
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
    expect(network_id).to include("networks") # IE: projects/tung-xxx/global/networks/ladybug
  end
end
