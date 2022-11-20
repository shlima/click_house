# frozen_string_literal: true

module ClickHouse
  module Middleware
    autoload :ResponseBase, 'click_house/middleware/response_base'
    autoload :SummaryMiddleware, 'click_house/middleware/summary_middleware'
    autoload :Logging, 'click_house/middleware/logging'
    autoload :ParseCsv, 'click_house/middleware/parse_csv'
    autoload :ParseJsonOj, 'click_house/middleware/parse_json_oj'
    autoload :ParseJson, 'click_house/middleware/parse_json'
    autoload :RaiseError, 'click_house/middleware/raise_error'
  end
end
