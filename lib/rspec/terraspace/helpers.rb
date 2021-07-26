module RSpec::Terraspace
  module Helpers
    extend Memoist

    def ts
      Ts.new
    end
    memoize :ts
    alias_method :terraspace, :ts
  end
end
