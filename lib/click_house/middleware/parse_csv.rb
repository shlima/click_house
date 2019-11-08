# frozen_string_literal: true

module ClickHouse
  module Middleware
    class ParseCsv < FaradayMiddleware::ResponseMiddleware
      Faraday::Response.register_middleware self => self

      dependency do
        require 'csv' unless defined?(CSV)
      end

      define_parser do |body, parser_options|
        CSV.parse(body, parser_options || {}) unless body.strip.empty?
      end
    end
  end
end
