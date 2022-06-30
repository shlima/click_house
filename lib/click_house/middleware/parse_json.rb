# frozen_string_literal: true

require 'faraday_middleware/response_middleware'
module ClickHouse
  module Middleware
    class ParseJson < FaradayMiddleware::ResponseMiddleware
      Faraday::Response.register_middleware self => self

      def call(environment)
        @app.call(environment).on_complete do |env|
          process_response(env) if parse_response?(env)
        end
      end

      define_parser do |body, parser_options|
        ::JSON.parse(body, parser_options || {}) if !body.strip.empty? && body =~ /^\{/
      end
    end
  end
end
