# frozen_string_literal: tru

RSpec.configure do |config|
  config.around(:each) do |example|
    ClickHouse.connection = nil
    example.run
  end
end
