# frozen_string_literal: true

# @return [Boolean]
# @param version [String] like "2.7"
def ruby_version_gt(version)
  Gem::Version.new(RUBY_VERSION) > Gem::Version.new(version)
end

# @return [Boolean]
# @param version [String] like "2.7"
def ruby_version_lt(version)
  Gem::Version.new(RUBY_VERSION) < Gem::Version.new(version)
end
