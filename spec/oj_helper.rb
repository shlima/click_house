# frozen_string_literal: tru

RSpec.configure do |config|
  config.before(:each) do
    ClickHouse.config do |c|
      c.json_parser = ClickHouse::Middleware::ParseJsonOj
      c.json_serializer = ClickHouse::Serializer::JsonOjSerializer
    end
  end
end
