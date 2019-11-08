# frozen_string_literal: true

module ClickHouse
  module Middleware
    autoload :Logging, 'click_house/middleware/logging'
    autoload :ParseCsv, 'click_house/middleware/parse_csv'
    autoload :RaiseError, 'click_house/middleware/raise_error'
  end
end
