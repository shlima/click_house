# frozen_string_literal: true

module ClickHouse
  Exception = Class.new(StandardError)
  NetworkException = Class.new(Exception)
  DbException = Class.new(Exception)
end
