module RSpec::Terraspace
  module Helpers
    extend Memoist

    def ts
      Ts.new
    end
    memoize :ts
    alias_method :terraspace, :ts

    def test_harness
      TestHarness.new
    end
    memoize :test_harness
  end
end
