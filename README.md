# rspec-terraspace

[![BoltOps Badge](https://img.boltops.com/boltops/badges/boltops-badge.png)](https://www.boltops.com)

Terraspec rspec helper methods. The usual testing process is:

1. Build a test harness. The test harness is a generated terraspace project with the specified modules and stacks.
2. Runs a `terraspace up` (`terraform apply`) to create real resources.
3. Check the resources. In this case, it simply checks for the terraform output.
4. Runs a `terraspace down` (`terraform destroy`) to clean up the real resources.

## Test harness location

Where is the generated test harness located?

The test hardness is materialized in `/tmp/terraspace/test-harnesses/NAME` by default. The build root can be controlled with `TS_RSPEC_BUILD_ROOT` env var.

So if you set it: `export TS_RSPEC_BUILD_ROOT=~/environment/terraspace-test-harnesses`. It will be built at `~/environment/terraspace-test-harnesses/NAME` instead.

## Module-Level and Project-Level Tests

The test helpers support both module-level and project-level tests. See:

* [Terraspace Testing](https://terraspace.cloud/docs/testing/)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-terraspace'
```

And then execute:

    $ bundle install

