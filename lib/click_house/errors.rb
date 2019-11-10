# frozen_string_literal: true

module ClickHouse
  Error = Class.new(StandardError)
  NetworkException = Class.new(Error)
  DbException = Class.new(Error)
  StatementException = Class.new(Error)
end
