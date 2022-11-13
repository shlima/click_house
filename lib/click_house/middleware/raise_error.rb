# frozen_string_literal: true

module ClickHouse
  module Middleware
    class RaiseError < Faraday::Middleware
      EXCEPTION_CODE_HEADER = 'x-clickhouse-exception-code'

      Faraday::Response.register_middleware self => self

      # @param env [Faraday::Env]
      def call(env)
        super
      rescue Faraday::ConnectionFailed => e
        raise NetworkException, e.message, e.backtrace
      end

      # @param env [Faraday::Env]
      def on_complete(env)
        if env.response_headers.include?(EXCEPTION_CODE_HEADER) || !env.success?
          raise DbException, "[#{env.status}] #{env.body}"
        end
      end
    end
  end
end
