source "https://rubygems.org"

# Specify your gem's dependencies in rspec-terraspace.gemspec
gemspec

gem "rake", "~> 12.0"
gem "rspec", "~> 3.0"

group :development, :test do
  if ENV['TS_EDGE']
    base = ENV['TS_EDGE_ROOT'] || "#{ENV['HOME']}/environment/terraspace-edge"
    gem "terraspace", path: "#{base}/terraspace"
  else
    gem "terraspace"
  end
end
