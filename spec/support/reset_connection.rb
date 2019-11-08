# frozen_string_literal: tru

SYSTEM_DATABASES = %w[default system].freeze

RSpec.configure do |config|
  config.around(:each) do |example|
    ClickHouse.connection = nil
    example.run
  end
end
