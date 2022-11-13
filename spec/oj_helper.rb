# frozen_string_literal: tru

RSpec.configure do |config|
  config.before(:each) do
    ClickHouse.config do |c|
      c.json_parser = ClickHouse::Middleware::ParseJsonOj
    end
  end
end
